package cc.minos.bigbluebutton
{
	import cc.minos.bigbluebutton.events.BigBlueButtonEvent;
	import cc.minos.bigbluebutton.model.ConferenceParameters;
	import cc.minos.bigbluebutton.plugins.Plugin;
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
	 * ...
	 * @author Minos
	 */
	public class BigBlueButton extends EventDispatcher
	{
		public static const version:Number = 0.8;
		
		private var _conferenceParameters:ConferenceParameters;
		public var plugins:Dictionary = new Dictionary();
		private var _netConnection:NetConnection;
		private var tried_tunneling:Boolean = false;
		private var logoutOnUserCommand:Boolean = false;
		
		public function BigBlueButton()
		{
			buildNetConnection();
		}
		
		public function addPlugin( pi:Plugin ):void
		{
			plugins[ pi.shortcut ] = pi;
			pi.setup( this );
			trace( "Loading Plugin: " + pi.name );
			pi.init();
		}
		
		public function delPlugin( shortcut:String ):void
		{
			var pi:Plugin = getPlugin( shortcut );
			if ( pi )
			{
				pi.stop();
				plugins[ pi.shortcut ] = null;
				pi = null;
			}
		}
		
		public function getPlugin( shortcut:String ):Plugin
		{
			return plugins[ shortcut ];
		}
		
		public function hasPlugin( shortcut:String ):Boolean
		{
			return getPlugin( shortcut ) != null;
		}
		
		public function connect( tunnel:Boolean = false ):void
		{
			if ( _conferenceParameters == null )
			{
				return;
			}
			tried_tunneling = tunnel;
			try
			{
				var uri:String = _conferenceParameters.protocol +"://" + _conferenceParameters.host + "/bigbluebutton/" + _conferenceParameters.room;
				_netConnection.connect( 
					uri, 
					_conferenceParameters.username, 
					_conferenceParameters.role, 
					_conferenceParameters.conference, 
					_conferenceParameters.room, 
					_conferenceParameters.voicebridge, 
					_conferenceParameters.record, 
					_conferenceParameters.externUserID, 
					_conferenceParameters.internalUserID );
				
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
		
		public function disconnect( logoutOnUserCommand:Boolean ):void
		{
			
			_netConnection.close();
		}
		
		public function set conferenceParameters( value:ConferenceParameters ):void
		{
			_conferenceParameters = value;
		}
		
		public function get conferenceParameters():ConferenceParameters
		{
			return _conferenceParameters;
		}
		
		private function buildNetConnection():void
		{
			_netConnection = new NetConnection();
			_netConnection.client = this;
			_netConnection.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
			_netConnection.addEventListener( AsyncErrorEvent.ASYNC_ERROR, onNetAsyncError );
			_netConnection.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onNetSecurityError );
			_netConnection.addEventListener( IOErrorEvent.IO_ERROR, onNetIOError );
		}
		
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
						trace( "Connection to viewers application failed...even when tunneling" );
						sendConnectionFailedEvent( BigBlueButtonEvent.CONNECTION_FAILED );
					}
					else
					{
						disconnect( false );
						trace( "Connection to viewers application failed...try tunneling" );
						var rtmptRetryTimer:Timer = new Timer( 1000, 1 );
						rtmptRetryTimer.addEventListener( "timer", rtmptRetryTimerHandler );
						rtmptRetryTimer.start();
					}
					break;
				case "NetConnection.Connect.Closed": 
					//LogUtil.debug( NAME + ":Connection to viewers application closed" );
	//          if (logoutOnUserCommand) {
						sendConnectionFailedEvent( BigBlueButtonEvent.CONNECTION_CLOSED );
	//          } else {
	//            autoReconnectTimer.addEventListener("timer", autoReconnectTimerHandler);
	//            autoReconnectTimer.start();		
//          }
					break;
				case "NetConnection.Connect.InvalidApp": 
					trace( ":viewers application not found on server" );
					sendConnectionFailedEvent( BigBlueButtonEvent.INVALID_APP );
					break;
				case "NetConnection.Connect.AppShutDown": 
					trace( ":viewers application has been shutdown" );
					sendConnectionFailedEvent( BigBlueButtonEvent.APP_SHUTDOWN );
					break;
				case "NetConnection.Connect.Rejected": 
					trace( ":Connection to the server rejected. Uri: " + _netConnection.uri + ". Check if the red5 specified in the uri exists and is running" );
					sendConnectionFailedEvent( BigBlueButtonEvent.CONNECTION_REJECTED );
					break;
				case "NetConnection.Connect.NetworkChange": 
					trace( "Detected network change. User might be on a wireless and temporarily dropped connection. Doing nothing. Just making a note." );
					break;
				default: 
					trace( ":Default status to the viewers application" );
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
		
		private function sendConnectionSuccessEvent():void
		{
			var event:BigBlueButtonEvent = new BigBlueButtonEvent( BigBlueButtonEvent.USER_LOGGED_IN );
			dispatchEvent( event );
		}
		
		private function sendConnectionFailedEvent( reason:String ):void
		{
			if ( this.logoutOnUserCommand )
			{
				sendUserLoggedOutEvent();
				return;
			}
			
			var e:BigBlueButtonEvent = new BigBlueButtonEvent( reason );
			dispatchEvent( e );
		}
		
		private function sendUserLoggedOutEvent():void
		{
			var e:BigBlueButtonEvent = new BigBlueButtonEvent( BigBlueButtonEvent.USER_LOGGED_OUT );
			dispatchEvent( e );
		}
		
		public function setUserId( id:Number, role:String ):String
		{
			trace( "setUserId: " + id );
			if ( isNaN( id ) )
				return "FAILED";
			return "OK";
		}
		
		public function sendMessage( service:String, onSuccess:Function = null, onFailed:Function = null, message:Object = null ):void
		{
			var responder:Responder = new Responder( function( result:Object ):void
				{
					if ( onSuccess !=null )
						onSuccess( result );
				}, function( status:Object ):void
				{
					if ( onFailed !=null )
						onFailed( status );
				} );
			if ( message != null )
				_netConnection.call( service, responder, message );
			else
				_netConnection.call( service, responder );
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
			trace( "bandwidth = " + p_bw + " Kbps." );
		}
	}

}