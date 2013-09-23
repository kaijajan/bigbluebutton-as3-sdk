
package cc.minos.bigbluebutton.plugins
{
	import cc.minos.bigbluebutton.model.BBBUser;
	import cc.minos.bigbluebutton.plugins.voice.*;
	import flash.media.Microphone;
	import flash.net.NetStream;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class VoicePlugin extends Plugin
	{
		private var connectionManager:ConnectionManager;
		private var streamManager:StreamManager;
		
		private var onCall:Boolean = false;
		private var rejoining:Boolean = false;
		private var userHangup:Boolean = false;
		private var options:VoiceOptions;
		
		public function VoicePlugin( options:VoiceOptions = null )
		{
			super();
			this.options = options;
			if ( this.options == null )
				this.options = new VoiceOptions();
			this.name = "[VoicePlugin]";
			this.shortcut = "voice";
			this.application = "sip";
		}
		
		override public function init():void
		{
			connectionManager = new ConnectionManager();
			connectionManager.addEventListener( CallConnectedEvent.CALL_CONNECTED_EVENT, onCallConnected );
			connectionManager.addEventListener( CallDisconnectedEvent.CALL_DISCONNECTED_EVENT, onCallDisconnected );
			connectionManager.addEventListener( ConnectionStatusEvent.CONNECTION_STATUS_EVENT, onConnectionStatus );
			streamManager = new StreamManager();
		}
		
		private function onConnectionStatus( e:ConnectionStatusEvent ):void
		{
			if ( e.status == ConnectionStatusEvent.SUCCESS )
			{
				connectionManager.doCall( bbb.conferenceParameters.webvoiceconf );
			}
		}
		
		private function onCallConnected( e:CallConnectedEvent ):void
		{
			streamManager.setConnection( connectionManager.connection );
			streamManager.callConnected( e.playStreamName, e.publishStreamName, e.codec );
			onCall = true;
			rejoining = false;
		}
		
		private function onCallDisconnected( e:CallDisconnectedEvent ):void
		{
			//left ? rejoin
		}
		
		override public function start():void
		{
			if ( me == null )
			{
				return;
			}
			userHangup = false;
			setupMic();
			var uid:String = String( Math.floor( new Date().getTime() ) );
			var uname:String = encodeURIComponent( me.userID + "-bbbID-" + me.name );
			connectionManager.connect( uid, me.externUserID, uname, bbb.conferenceParameters.room, uri );
		}
		
		public function rejoin():void
		{
			if ( !rejoining && !userHangup )
			{
				rejoining = true;
				start();
			}
		}
		
		private function setupMic():void
		{
			if ( noMicrophone() )
				streamManager.initWithNoMicrophone();
			else
				streamManager.initMicrophone();
		}
		
		override public function stop():void
		{
			if ( onCall )
			{
				streamManager.stopStreams();
				connectionManager.doHangUp();
				onCall = false;
			}
		}
		
		public function noMicrophone():Boolean
		{
			return (( Microphone.getMicrophone() == null ) || ( Microphone.names.length == 0 ) || (( Microphone.names.length == 1 ) && ( Microphone.names[ 0 ] == "Unknown Microphone" ) ) );
		}
		
		private function get me():BBBUser
		{
			return bbb.plugins[ 'users' ].getMe();
		}
	}
}