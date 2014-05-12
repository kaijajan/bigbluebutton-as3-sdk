
package cc.minos.bigbluebutton.core
{
	import avmplus.variableXml;
	import cc.minos.bigbluebutton.core.BaseConnection;
	import cc.minos.bigbluebutton.core.BaseConnectionCallback;
	import cc.minos.bigbluebutton.core.IVoiceConnection;
	import cc.minos.bigbluebutton.events.VideoConnectionEvent;
	import cc.minos.bigbluebutton.events.VoiceConferenceEvent;
	import flash.events.AsyncErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Microphone;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class VoiceConnection extends BaseConnectionCallback implements IVoiceConnection
	{
		
		protected var bc:BaseConnection;
		protected var incomingStream:NetStream;
		protected var outgoingStream:NetStream;
		protected var codec:String;
		protected var dial:String;
		protected var mic:Microphone;
		protected var voicename:String;
		
		public function VoiceConnection()
		{
			super();
			bc = new BaseConnection( this );
		}
		
		public function connect( uri:String, externUID:String, voicename:String, dial:String, mic:Microphone ):void
		{
			if ( bc.connection.connected ) 
				return;
			this.voicename = voicename;
			this.mic = mic;
			this.dial = dial;
			bc.connect( uri, externUID, voicename );
		}
		
		public function disconnect( userCommand:Boolean ):void
		{
			hangup();
			bc.disconnect( userCommand );
		}
		
		public function failedToJoinVoiceConferenceCallback( message:String ):*
		{
			trace( "[VoiceConnection] failedToJoinVoiceConferenceCallback" );
			var failedEvt:VoiceConferenceEvent = new VoiceConferenceEvent( VoiceConferenceEvent.DISCONNECTED );
			dispatchEvent( failedEvt );
		}
		
		public function disconnectedFromJoinVoiceConferenceCallback( message:String ):*
		{
			trace( "[VoiceConnection] disconnectedFromJoinVoiceConferenceCallback" );
			var failedEvt:VoiceConferenceEvent = new VoiceConferenceEvent( VoiceConferenceEvent.DISCONNECTED );
			dispatchEvent( failedEvt );
		}
		
		public function successfullyJoinedVoiceConferenceCallback( publishName:String, playName:String, codec:String ):*
		{
			trace( "[VoiceConnection] successfullyJoinedVoiceConferenceCallback" );
			var joinedEvt:VoiceConferenceEvent = new VoiceConferenceEvent( VoiceConferenceEvent.JOINED );
			dispatchEvent( joinedEvt );
			
			setupIncomingStream();
			
			if ( mic != null )
			{
				setupOutgoingStream();
			}
			
			setupPlayStatusHandler();
			
			incomingStream.play( playName );
			if ( mic != null )
			{
				outgoingStream.publish( publishName, "live" );
			}
		}
		
		private function setupIncomingStream():void
		{
			incomingStream = new NetStream( connection );
			incomingStream.addEventListener( NetStatusEvent.NET_STATUS, netStatus );
			incomingStream.addEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler );
			incomingStream.bufferTime = 0;
			incomingStream.receiveAudio( true );
			incomingStream.receiveVideo( false );
		}
		
		private function netStatus( e:NetStatusEvent ):void
		{
			trace( e.info.code );
		}
		
		private function asyncErrorHandler( e:AsyncErrorEvent ):void
		{
			trace( e.type );
		}
		
		private function setupOutgoingStream():void
		{
			outgoingStream = new NetStream( connection );
			outgoingStream.addEventListener( NetStatusEvent.NET_STATUS, netStatus );
			outgoingStream.addEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler );
			outgoingStream.attachAudio( mic );
		}
		
		private function setupPlayStatusHandler():void
		{
			var custom_obj:Object = new Object();
			custom_obj.onPlayStatus = playStatus;
			custom_obj.onMetaData = onMetaData;
			incomingStream.client = custom_obj;
			if ( mic != null )
				outgoingStream.client = custom_obj;
		}
		
		private function onMetaData( info:Object ):void
		{
			trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
		}
		
		private function playStatus( status:Object ):void
		{
			trace("play status: " + status );
		}
		
		public function call():void
		{
			connection.call( "voiceconf.call", null, "default", voicename, dial );
		}
		
		public function hangup():void
		{
			if ( !bc.connection.connected ) 
				return;
			stopStream();
			connection.call( "voiceconf.hangup", null, "default" );
		}
		
		private function stopStream():void
		{
			if ( incomingStream )
			{
				incomingStream.play( false );
			}
			
			if ( outgoingStream )
			{
				outgoingStream.attachAudio( null );
				outgoingStream.close();
			}
		}
		
		override internal function onSuccess( reason:String = "" ):void
		{
			super.onSuccess( reason );
			call();
		}
		
		override internal function onFailed( reason:String = "" ):void
		{
			super.onFailed(reason);
			disconnect(false);
		}
		
		public function get connection():NetConnection
		{
			return bc.connection;
		}
	
	}
}