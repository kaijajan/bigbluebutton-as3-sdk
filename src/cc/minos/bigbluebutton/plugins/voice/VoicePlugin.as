package cc.minos.bigbluebutton.plugins.voice
{
	import cc.minos.bigbluebutton.events.BigBlueButtonEvent;
	import cc.minos.bigbluebutton.plugins.Plugin;
	import cc.minos.bigbluebutton.plugins.users.UsersPlugin;
	import cc.minos.bigbluebutton.plugins.voice.events.*;
	import flash.events.StatusEvent;
	import flash.media.Microphone;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	
	/**
	 * 語音應用
	 * 連接到語音服務器
	 * @author Minos
	 */
	public class VoicePlugin extends Plugin
	{
		/** 連接管理 */
		private var connectionManager:ConnectionManager;
		/** 音頻流管理 */
		private var streamManager:StreamManager;
		/** 已經加入 */
		private var _onCall:Boolean = false;
		/** 正在加入 */
		private var rejoining:Boolean = false;
		/** 是否用戶掛斷 */
		private var userHangup:Boolean = false;
		/** */
		public var options:VoiceOptions;
		
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
		
		/**
		 *
		 */
		override protected function init():void
		{
			connectionManager = new ConnectionManager( this );
			streamManager = new StreamManager( this );
			this.addEventListener( ConnectionEvent.CALL_CONNECTED, onCallConnected );
			this.addEventListener( ConnectionEvent.CALL_DISCONNECTED, onCallDisconnected );
			this.addEventListener( ConnectionStatusEvent.CONNECTION_STATUS_EVENT, onConnectionStatus );
		}
		
		/**
		 * 服務器連接狀態
		 * @param	e
		 */
		private function onConnectionStatus( e:ConnectionStatusEvent ):void
		{
			connectionManager.doCall( bbb.conferenceParameters.webvoiceconf );
		}
		
		/**
		 * 音頻連接成功
		 * @param	e
		 */
		private function onCallConnected( e:ConnectionEvent ):void
		{
			streamManager.setConnection( connection );
			streamManager.callConnected( e.playStreamName, e.publishStreamName, e.codec );
			onCall = true;
			rejoining = false;
			
			if ( options.muteAll && presenter )
			{
				UsersPlugin( bbb.getPlugin( 'users' ) ).muteAllUsers(true);
			}
		}
		
		/**
		 * 服務器連接失敗或斷開
		 * @param	e
		 */
		private function onCallDisconnected( e:ConnectionEvent ):void
		{
			//left ? rejoin
			hangup();
			rejoin();
		}
		
		override public function get connection():NetConnection 
		{
			return connectionManager.connection;
		}
		
		/**
		 * 啟動語音應用
		 */
		override public function start():void
		{
			if ( options.autoJoin )
			{
				if ( options.skipCheck || noMicrophone() )
				{
					join();
				}
				else
				{
					dispatchRawEvent( new BigBlueButtonEvent( BigBlueButtonEvent.SHOW_MIC_SETTINGS ) );
				}
			}
		}
		
		/**
		 * 停止語音應用並且斷開連接
		 */
		override public function stop():void
		{
			userRequestedHangup();
			connectionManager.disconnect();
		}
		
		/**
		 * 加入語音
		 */
		public function join():void
		{
			userHangup = false;
			setupMic();
			var uid:String = String( Math.floor( new Date().getTime() ) );
			var uname:String = encodeURIComponent( bbb.conferenceParameters.externUserID + "-bbbID-" + bbb.conferenceParameters.username );
			connectionManager.connect( uid, bbb.conferenceParameters.internalUserID, uname, bbb.conferenceParameters.room, uri );
		}
		
		/**
		 * 重新加入
		 */
		public function rejoin():void
		{
			if ( !rejoining && !userHangup )
			{
				rejoining = true;
				join();
			}
		}
		
		/**
		 * 用戶退出語音
		 */
		public function userRequestedHangup():void
		{
			userHangup = true;
			hangup();
		}
		
		/**
		 * 退出語音
		 */
		public function hangup():void
		{
			if ( onCall )
			{
				streamManager.stopStreams();
				connectionManager.doHangUp();
				onCall = false;
			}
		}
		
		/**
		 * 設置麥克風
		 */
		private function setupMic():void
		{
			if ( noMicrophone() ) {
				trace("noMicrophone");
				streamManager.initWithNoMicrophone();
			}
			else 
			{
				trace("setupMic");
				streamManager.initMicrophone();
			}
		}
		
		/**
		 * 檢測麥克風
		 * @return 檢測不到麥克風返回true
		 */
		public function noMicrophone():Boolean
		{
			return (( Microphone.getMicrophone() == null ) || ( Microphone.names.length == 0 ) || (( Microphone.names.length == 1 ) && ( Microphone.names[ 0 ] == "Unknown Microphone" ) ) );
		}
		
		public function get onCall():Boolean
		{
			return _onCall;
		}
		
		public function set onCall( value:Boolean ):void
		{
			_onCall = value;
		}
	}
}