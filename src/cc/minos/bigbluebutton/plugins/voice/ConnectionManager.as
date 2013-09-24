package cc.minos.bigbluebutton.plugins.voice
{
	import cc.minos.bigbluebutton.plugins.VoicePlugin;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.*;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	/**
	 * 音頻連接管理器
	 */
	public class ConnectionManager
	{
		/** 網絡連接 */
		private var netConnection:NetConnection = null;
		/** 輸入流 */
		private var incomingNetStream:NetStream = null;
		/** 輸出流 */
		private var outgoingNetStream:NetStream = null;
		/** 用戶名 */
		private var username:String;
		/** 服務器地址 */
		private var uri:String;
		/** */
		private var uid:String;
		/** 房間id */
		private var room:String;
		/** 是否已經連接到服務器 */
		private var isConnected:Boolean = false;
		/** */
		private var registered:Boolean = false;
		private var plugin:VoicePlugin;
		
		public function ConnectionManager( plugin:VoicePlugin ):void
		{
			this.plugin = plugin;
		}
		
		public function get connection():NetConnection
		{
			return netConnection;
		}
		
		/**
		 * 開始連接語音服務器
		 * @param	uid
		 * @param	externUID
		 * @param	username
		 * @param	room
		 * @param	uri
		 */
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
		
		/**
		 *
		 * @param	externUID
		 * @param	username
		 */
		private function connectToServer( externUID:String, username:String ):void
		{
			NetConnection.defaultObjectEncoding = flash.net.ObjectEncoding.AMF0;
			netConnection = new NetConnection();
			netConnection.client = this;
			netConnection.addEventListener( NetStatusEvent.NET_STATUS, netStatus );
			netConnection.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
			netConnection.connect( uri, externUID, username );
		}
		
		/**
		 * 斷開服務器
		 */
		public function disconnect():void
		{
			netConnection.close();
		}
		
		/**
		 * 連接狀態處理
		 * @param	evt
		 */
		private function netStatus( evt:NetStatusEvent ):void
		{
			if ( evt.info.code == "NetConnection.Connect.Success" )
			{
				var event:ConnectionStatusEvent = new ConnectionStatusEvent();
				trace( "Successfully connected to voice application." );
				event.status = ConnectionStatusEvent.SUCCESS;
				trace( "Dispatching " + event.status );
				plugin.dispatchEvent( event );
				
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
			var disEvent:ConnectionEvent = new ConnectionEvent( ConnectionEvent.CALL_DISCONNECTED );
			plugin.dispatchEvent( disEvent );
			isConnected = false;
		}
		
		public function disconnectedFromJoinVoiceConferenceCallback( msg:String ):*
		{
			trace( "disconnectedFromJoinVoiceConferenceCallback " + msg );
			var disEvent:ConnectionEvent = new ConnectionEvent( ConnectionEvent.CALL_DISCONNECTED );
			plugin.dispatchEvent( disEvent );
			isConnected = false;
		}
		
		public function successfullyJoinedVoiceConferenceCallback( publishName:String, playName:String, codec:String ):*
		{
			trace( "successfullyJoinedVoiceConferenceCallback " + publishName + " : " + playName + " : " + codec );
			isConnected = true;
			var event:ConnectionEvent = new ConnectionEvent( ConnectionEvent.CALL_CONNECTED );
			event.publishStreamName = publishName;
			event.playStreamName = playName;
			event.codec = codec;
			plugin.dispatchEvent( event );
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
			//trace( "bandwidth = " + p_bw + " Kbps." );
		}
	}
}