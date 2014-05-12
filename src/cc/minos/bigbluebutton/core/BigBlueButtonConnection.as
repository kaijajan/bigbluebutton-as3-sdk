package cc.minos.bigbluebutton.core
{
	import cc.minos.bigbluebutton.core.BaseConnection;
	import cc.minos.bigbluebutton.core.BaseConnectionCallback;
	import cc.minos.bigbluebutton.core.IBigBlueButtonConnection;
	import cc.minos.bigbluebutton.events.BigBlueButtonEvent;
	import cc.minos.bigbluebutton.events.ConnectionSuccessEvent;
	import cc.minos.bigbluebutton.models.IConferenceParameters;
	import cc.minos.bigbluebutton.models.IConfig;
	import cc.minos.bigbluebutton.plugins.IPlugin;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class BigBlueButtonConnection extends BaseConnectionCallback implements IBigBlueButtonConnection
	{
		
		public var plugins:Dictionary;
		
		private var _userID:String;
		private var _conferenceParameters:IConferenceParameters;
		private var _config:IConfig;
		
		protected var bc:BaseConnection;
		protected var messageListeners:Vector.<IMessageListener>;
		protected var tunnel:Boolean;
		
		public function BigBlueButtonConnection( config:IConfig )
		{
			_config = config;
			plugins = new Dictionary();
			tunnel = false;
			bc = new BaseConnection( this );
			messageListeners = new Vector.<IMessageListener>();
		}
		
		override internal function onSuccess( reason:String = "" ):void
		{
			send( "getMyUserId", new Responder( 
				//success
				function( result:Object ):void
				{
					trace( "[BBB] My userID is " + result.toString() );
					_userID = result.toString();
					_conferenceParameters.userid = _userID;
					
					var loginEvent:BigBlueButtonEvent = new BigBlueButtonEvent( BigBlueButtonEvent.USER_LOGIN );
					dispatchEvent( loginEvent );
				}, 
				//failed
				function( status:Object ):void
				{
				} ) );
		}
		
		override internal function onFailed( reason:String = "" ):void
		{
			//super.onFailed(reason);
			var failedEvent:BigBlueButtonEvent = new BigBlueButtonEvent( BigBlueButtonEvent.USER_LOGOUT )
			dispatchEvent( failedEvent );
		}
		
		public function connect( params:IConferenceParameters, tunnel:Boolean = false ):void
		{
			this.tunnel = tunnel;
			this._conferenceParameters = params;
			
			var uri:String = "rtmp://" + _config.host + "/bigbluebutton/" + _conferenceParameters.room;
			
			bc.connect( uri, //服務器地址
				_conferenceParameters.username, //用戶名
				_conferenceParameters.role, //權限
				_conferenceParameters.room, //房間
				_conferenceParameters.voicebridge, //語音通道（類似於房間id）
				_conferenceParameters.record, //是否記錄
				_conferenceParameters.externUserID, //外部id
				_conferenceParameters.internalUserID ); //內部id
			
			if ( _conferenceParameters.record )
			{
				trace( "recording.." );
			}
		}
		
		public function disconnect( userCommand:Boolean ):void
		{
			removeAllPlugin();
			bc.disconnect( userCommand );
		}
		
		public function send( cmd:String, ... params ):void
		{
			bc.connection.call.apply( null, new Array( cmd ).concat( params ) );
		}
		
		/**
		 *
		
		 */
		public function onMessageFromServer( messageName:String, message:Object ):void
		{
			if ( messageName != null && messageName != "" )
			{
				//trace( messageName , message );
				for ( var notify:String in messageListeners )
				{
					messageListeners[ notify ].onMessage( messageName, message );
				}
			}
			else
			{
				
			}
		}
		
		/**
		 *
		
		 */
		public function addMessageListener( listener:IMessageListener ):void
		{
			messageListeners.push( listener );
		}
		
		/**
		 *
		
		 */
		public function removeMessageListener( listener:IMessageListener ):void
		{
			for ( var ob:int = 0; ob < messageListeners.length; ob++ )
			{
				if ( messageListeners[ ob ] == listener )
				{
					messageListeners.splice( ob, 1 );
					break;
				}
			}
		}
		
		/**
		 *
		
		 */
		public function addPlugin( plugin:IPlugin ):void
		{
			if ( hasPlugin( plugin.shortcut ) )
			{
				removePlugin( plugin.shortcut );
			}
			plugins[ plugin.shortcut ] = plugin;
			plugin.setup( this );
		}
		
		/**
		 *
		
		 */
		public function removePlugin( shortcut:String ):void
		{
			var plugin:IPlugin = getPlugin( shortcut );
			if ( plugin )
			{
				plugin.stop();
				delete plugins[ plugin.shortcut ];
				plugin = null;
			}
		}
		
		/**
		 *
		
		 */
		public function getPlugin( shortcut:String ):IPlugin
		{
			return plugins[ shortcut ];
		}
		
		/**
		 *
		
		 */
		public function hasPlugin( shortcut:String ):Boolean
		{
			return plugins[ shortcut ] != null;
		}
		
		public function startAllPlugin():void
		{
			for each ( var p:IPlugin in plugins )
			{
				if ( p )
				{
					p.start();
				}
			}
		}
		
		public function removeAllPlugin():void
		{
			for ( var sc:String in plugins )
			{
				removePlugin( sc );
			}
		}
		
		///////////////////////
		// GETTERS/SETTERS
		///////////////////////
		
		public function get userID():String
		{
			return _userID;
		}
		
		public function get connection():NetConnection
		{
			return bc.connection;
		}
		
		public function get conferenceParameters():IConferenceParameters
		{
			return _conferenceParameters;
		}
		
		public function get config():IConfig
		{
			return _config;
		}
	
	}
}