package cc.minos.bigbluebutton.plugins.voice
{
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.*;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class ConnectionManager extends EventDispatcher
	{
		private var netConnection:NetConnection = null;
		private var incomingNetStream:NetStream = null;
		private var outgoingNetStream:NetStream = null;
		private var username:String;
		private var uri:String;
		private var uid:String;
		private var room:String;
		
		private var isConnected:Boolean = false;
		private var registered:Boolean = false;
		
		public function ConnectionManager():void
		{
		}
		
		public function get connection():NetConnection
		{
			return netConnection;
		}
		
		public function connect( uid:String, externUID:String, username:String, room:String, uri:String ):void
		{
			if ( isConnected )
				return;
			isConnected = true;
			
			this.uid = uid;
			this.username = username;
			this.room = room;
			this.uri = uri;
			connectToServer( externUID, username );
		}
		
		private function connectToServer( externUID:String, username:String ):void
		{
			NetConnection.defaultObjectEncoding = flash.net.ObjectEncoding.AMF0;
			netConnection = new NetConnection();
			netConnection.client = this;
			netConnection.addEventListener( NetStatusEvent.NET_STATUS, netStatus );
			netConnection.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
			netConnection.connect( uri, externUID, username );
		}
		
		public function disconnect():void
		{
			netConnection.close();
		}
		
		private function netStatus( evt:NetStatusEvent ):void
		{
			if ( evt.info.code == "NetConnection.Connect.Success" )
			{
				var event:ConnectionStatusEvent = new ConnectionStatusEvent();
				trace( "Successfully connected to voice application." );
				event.status = ConnectionStatusEvent.SUCCESS;
				trace( "Dispatching " + event.status );
				dispatchEvent( event );
				
			}
			else if ( evt.info.code == "NetConnection.Connect.NetworkChange" )
			{
				trace( "Detected network change. User might be on a wireless and temporarily dropped connection. Doing nothing. Just making a note." );
			}
			else
			{
				trace( "Connection event info [" + evt.info.code + "]. Disconnecting." );
				disconnect();
			}
		}
		
		private function asyncErrorHandler( event:AsyncErrorEvent ):void
		{
			trace( "AsyncErrorEvent: " + event );
		}
		
		private function securityErrorHandler( event:SecurityErrorEvent ):void
		{
			trace( "securityErrorHandler: " + event );
		}
		
		public function call():void
		{
			//LogUtil.debug( "in call - Calling " + room );
			doCall( room );
		}
		
		//********************************************************************************************
		//			
		//			CallBack Methods from Red5 
		//
		//********************************************************************************************		
		public function failedToJoinVoiceConferenceCallback( msg:String ):*
		{
			trace( "failedToJoinVoiceConferenceCallback " + msg );
			var event:CallDisconnectedEvent = new CallDisconnectedEvent();
			dispatchEvent( event );
			isConnected = false;
		}
		
		public function disconnectedFromJoinVoiceConferenceCallback( msg:String ):*
		{
			trace( "disconnectedFromJoinVoiceConferenceCallback " + msg );
			var event:CallDisconnectedEvent = new CallDisconnectedEvent();
			dispatchEvent( event );
			isConnected = false;
		}
		
		public function successfullyJoinedVoiceConferenceCallback( publishName:String, playName:String, codec:String ):*
		{
			trace( "successfullyJoinedVoiceConferenceCallback " + publishName + " : " + playName + " : " + codec );
			isConnected = true;
			var event:CallConnectedEvent = new CallConnectedEvent();
			event.publishStreamName = publishName;
			event.playStreamName = playName;
			event.codec = codec;
			dispatchEvent( event );
		}
		
		//********************************************************************************************
		//			
		//			SIP Actions
		//
		//********************************************************************************************		
		public function doCall( dialStr:String ):void
		{
			trace( "in doCall - Calling " + dialStr );
			netConnection.call( "voiceconf.call", null, "default", username, dialStr );
		}
		
		public function doHangUp():void
		{
			if ( isConnected )
			{
				netConnection.call( "voiceconf.hangup", null, "default" );
				isConnected = false;
			}
		}
		
		public function onBWCheck( ... rest ):Number
		{
			return 0;
		}
		
		public function onBWDone( ... rest ):void
		{
			var p_bw:Number;
			if ( rest.length > 0 )
				p_bw = rest[ 0 ];
			// your application should do something here 
			// when the bandwidth check is complete 
			trace( "bandwidth = " + p_bw + " Kbps." );
		}
	}
}