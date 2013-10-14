package cc.minos.bigbluebutton
{
	import cc.minos.bigbluebutton.events.*;
	import cc.minos.bigbluebutton.interfaces.*;
	import cc.minos.bigbluebutton.model.*;
	import cc.minos.bigbluebutton.plugins.*;
	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * BBB主類，通過添加應用開啟不同功能。
	 * **用戶應用（UsersPlugin）是必須開啟的**
	 * **開始連接前需設置配置參數ConferenceParaameters**
	 * @author Minos
	 */
	public class BigBlueButton extends EventDispatcher implements IPluginManager, IMessageManager
	{
		/** 服務器版本 */
		public static const API:Number = 0.81;
		
		public static const VERSION:Number = 0.3;
		
		/** 應用目錄 */
		public var plugins:Dictionary = new Dictionary();
		
		/** 配置 */
		private var _conferenceParameters:ConferenceParameters;
		
		/** 網絡連接 */
		private var _netConnection:NetConnection;
		
		/** 通道 */
		private var tried_tunneling:Boolean = false;
		
		/** 用戶退出 */
		private var logoutOnUserCommand:Boolean = false;
		
		/** 偵聽器目錄 */
		private var _messageListeners:Vector.<IMessageListener>;
		
		public function BigBlueButton()
		{
			_messageListeners = new Vector.<IMessageListener>();
			buildNetConnection();
		}
		
		/**
		 * 連接服務器（必須先設置配置)
		 * @param	tunnel
		 */
		public function connect( tunnel:Boolean = false ):void
		{
			if ( _conferenceParameters == null )
			{
				trace( "配置未設置" );
				return;
			}
			tried_tunneling = tunnel;
			try
			{
				var uri:String = _conferenceParameters.protocol + "://" + _conferenceParameters.host + "/bigbluebutton/" + _conferenceParameters.room;
				_netConnection.connect( uri, //服務器地址
					_conferenceParameters.username, //用戶名
					_conferenceParameters.role, //權限
					_conferenceParameters.room, //房間
					_conferenceParameters.voicebridge, //語音通道（類似於房間id）
					_conferenceParameters.record, //是否記錄
					_conferenceParameters.externUserID, //外部id
					_conferenceParameters.internalUserID ); //內部id
				
			}
			catch ( e:ArgumentError )
			{
				switch ( e.errorID )
				{
					case 2004: 
						trace( "Error! Invalid server location: " + uri );
						break;
					default: 
						trace( "UNKNOWN Error! Invalid server location: " + uri );
						break;
				}
			}
		}
		
		/**
		 * 斷開連接
		 * @param	logoutOnUserCommand		:	是否用戶操作
		 */
		public function disconnect( logoutOnUserCommand:Boolean ):void
		{
			this.logoutOnUserCommand = logoutOnUserCommand;
			_netConnection.close();
		}
		
		/**
		 * 設置配置
		 */
		public function set conferenceParameters( value:ConferenceParameters ):void
		{
			_conferenceParameters = value;
		}
		
		/**
		 * 獲取配置
		 */
		public function get conferenceParameters():ConferenceParameters
		{
			return _conferenceParameters;
		}
		
		/**
		 * 創建網絡連接
		 */
		private function buildNetConnection():void
		{
			_netConnection = new NetConnection();
			_netConnection.client = this;
			_netConnection.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
			_netConnection.addEventListener( AsyncErrorEvent.ASYNC_ERROR, onNetAsyncError );
			_netConnection.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onNetSecurityError );
			_netConnection.addEventListener( IOErrorEvent.IO_ERROR, onNetIOError );
		}
		
		/**
		 * 網絡連接處理
		 * @param	e
		 */
		private function onNetStatus( e:Object ):void
		{
			switch ( e.info.code )
			{
				case "NetConnection.Connect.Success":
					
					_netConnection.call( "getMyUserId", new Responder( function( result:Object ):void
						{
							_conferenceParameters.connection = _netConnection;
							_conferenceParameters.userID = result.toString();
							sendConnectionSuccessEvent();
						}, function( status:Object ):void
						{
						} ) );
					
					break;
				case "NetConnection.Connect.Failed": 
					if ( tried_tunneling )
					{
						trace( "连接失败" );
						sendConnectionFailedEvent( BigBlueButtonEvent.CONNECTION_FAILED );
					}
					else
					{
						disconnect( false );
						trace( "连接失败，尝试使用通道" );
						var rtmptRetryTimer:Timer = new Timer( 1000, 1 );
						rtmptRetryTimer.addEventListener( "timer", rtmptRetryTimerHandler );
						rtmptRetryTimer.start();
					}
					break;
				case "NetConnection.Connect.Closed": 
					//if (logoutOnUserCommand) {
						sendConnectionFailedEvent( BigBlueButtonEvent.CONNECTION_CLOSED );
					//          } else {
					//            autoReconnectTimer.addEventListener("timer", autoReconnectTimerHandler);
					//            autoReconnectTimer.start();		
//          }
					break;
				case "NetConnection.Connect.InvalidApp": 
					trace( "错误应用" );
					sendConnectionFailedEvent( BigBlueButtonEvent.INVALID_APP );
					break;
				case "NetConnection.Connect.AppShutDown": 
					trace( "应用已经关闭" );
					sendConnectionFailedEvent( BigBlueButtonEvent.APP_SHUTDOWN );
					break;
				case "NetConnection.Connect.Rejected": 
					trace( "连接被拒绝" );
					sendConnectionFailedEvent( BigBlueButtonEvent.CONNECTION_REJECTED );
					break;
				case "NetConnection.Connect.NetworkChange": 
					break;
				default: 
					sendConnectionFailedEvent( BigBlueButtonEvent.UNKNOWN_REASON );
					break;
			}
		}
		
		private function rtmptRetryTimerHandler( e:TimerEvent ):void
		{
			connect( true );
		}
		
		private function onNetAsyncError( e:AsyncErrorEvent ):void
		{
			trace( "Asynchronous code error - " + e.error );
			sendConnectionFailedEvent( BigBlueButtonEvent.UNKNOWN_REASON );
		}
		
		private function onNetSecurityError( e:SecurityErrorEvent ):void
		{
			trace( "Security error - " + e.text );
			sendConnectionFailedEvent( BigBlueButtonEvent.UNKNOWN_REASON );
		}
		
		private function onNetIOError( e:IOErrorEvent ):void
		{
			trace( "Input/output error - " + e.text );
			sendConnectionFailedEvent( BigBlueButtonEvent.UNKNOWN_REASON );
		}
		
		/**
		 *
		 */
		private function sendConnectionSuccessEvent():void
		{
			var event:BigBlueButtonEvent = new BigBlueButtonEvent( BigBlueButtonEvent.USER_LOGGED_IN );
			dispatchEvent( event );
		}
		
		/**
		 *
		 * @param	reason
		 */
		private function sendConnectionFailedEvent( reason:String ):void
		{
			if ( this.logoutOnUserCommand )
			{
				var outEvent:BigBlueButtonEvent = new BigBlueButtonEvent( BigBlueButtonEvent.USER_LOGGED_OUT );
				dispatchEvent( outEvent );
				return;
			}
			
			var failedEvent:BigBlueButtonEvent = new BigBlueButtonEvent( reason );
			dispatchEvent( failedEvent );
		}
		
		public function setUserId( id:Number, role:String ):String
		{
			trace( "setUserId: " + id );
			if ( isNaN( id ) )
				return "FAILED";
			return "OK";
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
		}
		
		/* cc.minos.bigbluebutton.extensions.IMessageManager (信息管理接口)*/
		
		/**
		 * 添加信息偵聽器
		 * @param	listener
		 */
		public function addMessageListener( listener:IMessageListener ):void
		{
			_messageListeners.push( listener );
		}
		
		/**
		 * 移除信息偵聽器
		 * @param	listener
		 */
		public function removeMessageListener( listener:IMessageListener ):void
		{
			for ( var ob:int = 0; ob < _messageListeners.length; ob++ )
			{
				if ( _messageListeners[ ob ] == listener )
				{
					_messageListeners.splice( ob, 1 );
					break;
				}
			}
		}
		
		/**
		 * 由服務器調用，接受服務器的信息，並根據類型調用相應的信息接收器
		 * @param	messageName		:	信息類型
		 * @param	message			:	信息數據
		 */
		public function onMessageFromServer( messageName:String, message:Object ):void
		{
			if ( messageName != null && messageName != "" )
			{
				for ( var notify:String in _messageListeners )
				{
					_messageListeners[ notify ].onMessage( messageName, message );
				}
			}
			else
			{
				trace( "信息類型未定義" );
			}
		}
		
		/**
		 * 發送信息
		 * @param	args 參數數組[command, responder , ...rest ]
		 */
		public function send( args:Array ):void
		{
			_netConnection.call.apply( null, args );
		}
		
		/* cc.minos.bigbluebutton.extensions.IPluginManager （應用管理接口）*/
		
		/**
		 * 添加應用
		 * @param	pi	:	應用為Plugin的子類
		 */
		public function addPlugin( pi:Plugin ):void
		{
			plugins[ pi.shortcut ] = pi;
			pi.setup( this );
		}
		
		/**
		 * 移除應用
		 * @param	shortcut	:	應用的短名稱
		 */
		public function removePlugin( shortcut:String ):void
		{
			var pi:Plugin = getPlugin( shortcut );
			if ( pi )
			{
				pi.stop();
				delete plugins[ pi.shortcut ];
				pi = null;
			}
		}
		
		/**
		 * 獲取應用
		 * @param	shortcut	:	應用的短名稱
		 * @return	根據shortcut返回相應的應用
		 */
		public function getPlugin( shortcut:String ):Plugin
		{
			return plugins[ shortcut ];
		}
		
		/**
		 * 檢查是否存在應用
		 * @param	shortcut
		 * @return	根據shortcut檢查是否存在應用，存在則返回true，不存在為false
		 */
		public function hasPlugin( shortcut:String ):Boolean
		{
			return getPlugin( shortcut ) != null;
		}
	}

}