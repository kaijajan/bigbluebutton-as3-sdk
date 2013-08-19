
package cc.minos.bbb
{
	import cc.minos.bbb.events.*;
	import cc.minos.bbb.plugins.Plugin;
	import cc.minos.bbb.plugins.users.UsersPlugin;
	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.SharedObject;
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
		private var _userid:Number = -1;
		private var logoutOnUserCommand:Boolean = false;
		
		private var _messageListeners:Array = [];
		public function BigBlueButton()
		{
			//buildListeners();
			buildNetConnection();
		}
		
		/* INTERFACE cc.minos.bbb.IPluginManager */
		
		public function addPlugin( pi:Plugin ):void
		{
			plugins[ pi.shortcut ] = pi;
			pi.setInstance( this );
			trace( "Loading Plugin: " + pi.name );
			pi.init();
		}
		
		public function delPlugin( pi:Plugin ):void
		{
		}
		
		public function getPlugin( shortcut:String ):Plugin
		{
			return null;
		}
		
		/* INTERFACE cc.minos.bbb.IConnectionManager */
		
		public function connect( tunnel:Boolean = false ):void
		{
			if ( _conferenceParameters == null )
			{
				trace( "conference不能为空" );
				return;
			}
			
			tried_tunneling = tunnel;
			
			try
			{
				var uri:String = _conferenceParameters.uri + "/" + _conferenceParameters.room;
				_netConnection.connect( uri, _conferenceParameters.username, _conferenceParameters.role, _conferenceParameters.conference, _conferenceParameters.room, _conferenceParameters.voicebridge, _conferenceParameters.record, _conferenceParameters.externUserID, _conferenceParameters.internalUserID );
				
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
		
		/* NetConnection */
		
		private function buildNetConnection():void
		{
			_netConnection = new NetConnection();
			_netConnection.client = this;
			_netConnection.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
			_netConnection.addEventListener( AsyncErrorEvent.ASYNC_ERROR, onNetAsyncError );
			_netConnection.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onNetSecurityError );
			_netConnection.addEventListener( IOErrorEvent.IO_ERROR, onNetIOError );
		}
		
		private function onNetStatus( e:NetStatusEvent ):void
		{
			handleResult( e );
		}
		
		public function handleResult( e:Object ):void
		{
			switch ( e.info.code )
			{
				case "NetConnection.Connect.Success": 
					_netConnection.call( "getMyUserId", // Remote function name
						new Responder( function( result:Object ):void
						{
							_conferenceParameters.connection = _netConnection;
							_conferenceParameters.userid = result.toString();
							sendConnectionSuccessEvent();
						}, function( status:Object ):void
						{
						} ) //new Responder
						); //_netConnection.call
					
					break;
				case "NetConnection.Connect.Failed": 
					if ( tried_tunneling )
					{
						trace( "Connection to viewers application failed...even when tunneling" );
						sendConnectionFailedEvent( ConnectionFailedEvent.CONNECTION_FAILED );
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
					sendConnectionFailedEvent( ConnectionFailedEvent.CONNECTION_CLOSED );
//          } else {
//            autoReconnectTimer.addEventListener("timer", autoReconnectTimerHandler);
//            autoReconnectTimer.start();		
//          }
					break;
				
				case "NetConnection.Connect.InvalidApp": 
					//LogUtil.debug( NAME + ":viewers application not found on server" );
					sendConnectionFailedEvent( ConnectionFailedEvent.INVALID_APP );
					break;
				
				case "NetConnection.Connect.AppShutDown": 
					//LogUtil.debug( NAME + ":viewers application has been shutdown" );
					sendConnectionFailedEvent( ConnectionFailedEvent.APP_SHUTDOWN );
					break;
				
				case "NetConnection.Connect.Rejected": 
					//LogUtil.debug( NAME + ":Connection to the server rejected. Uri: " + _applicationURI + ". Check if the red5 specified in the uri exists and is running" );
					sendConnectionFailedEvent( ConnectionFailedEvent.CONNECTION_REJECTED );
					break;
				
				case "NetConnection.Connect.NetworkChange": 
					//LogUtil.info( "Detected network change. User might be on a wireless and temporarily dropped connection. Doing nothing. Just making a note." );
					break;
				
				default: 
					//LogUtil.debug( NAME + ":Default status to the viewers application" );
					sendConnectionFailedEvent( ConnectionFailedEvent.UNKNOWN_REASON );
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
			sendConnectionFailedEvent( ConnectionFailedEvent.UNKNOWN_REASON );
		}
		
		private function onNetSecurityError( e:SecurityErrorEvent ):void
		{
			trace( "Security error - " + e.text );
			sendConnectionFailedEvent( ConnectionFailedEvent.UNKNOWN_REASON );
		}
		
		private function onNetIOError( e:IOErrorEvent ):void
		{
			trace( "Input/output error - " + e.text );
			sendConnectionFailedEvent( ConnectionFailedEvent.UNKNOWN_REASON );
		}
		
		private function sendConnectionSuccessEvent():void
		{
			var event:ConnectionSuccessEvent = new ConnectionSuccessEvent( ConnectionSuccessEvent.USER_LOGGED_IN );
			dispatchEvent( event );
		}
		
		private function sendConnectionFailedEvent( reason:String ):void
		{
			if ( this.logoutOnUserCommand )
			{
				sendUserLoggedOutEvent();
				return;
			}
			
			var e:ConnectionFailedEvent = new ConnectionFailedEvent( reason );
			dispatchEvent( e );
		
			//attemptReconnect(backoff);
		}
		
		private function sendUserLoggedOutEvent():void
		{
			var e:ConnectionFailedEvent = new ConnectionFailedEvent( ConnectionFailedEvent.USER_LOGGED_OUT );
			dispatchEvent( e );
		}
		
		/* callback from server */
		
		public function setUserId( id:Number, role:String ):String
		{
			trace( "ViewersNetDelegate::setConnectionId: id=[" + id + "," + role + "]" );
			if ( isNaN( id ) )
				return "FAILED";
			
			// We should be receiving authToken and room from the server here.
			_userid = id;
			return "OK";
		}
		
		public function sendMessage( service:String, onSuccess:Function, onFailed:Function, message:Object = null ):void
		{
			var responder:Responder = new Responder( function( result:Object ):void
				{ // On successful result
					onSuccess( "Successfully sent [" + service + "]." );
				}, function( status:Object ):void
				{ // status - On error occurred
					var errorReason:String = "Failed to send [" + service + "]:\n";
					for ( var x:Object in status )
					{
						errorReason += "\t" + x + " : " + status[ x ];
					}
				} );
			if ( message != null )
				_netConnection.call( service, responder, message );
			else
				_netConnection.call( service, responder );
		}
		
		public function addMessageListener( listener:IMessageListener ):void
		{
			_messageListeners.push( listener );
		}
		
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
		
		private function notifyListeners( messageName:String, message:Object ):void
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
				trace( "Message name is undefined" );
			}
		}
		
		public function onMessageFromServer( messageName:String, result:Object ):void
		{
			trace( "Got message from server [" + messageName + "]" );
			notifyListeners( messageName, result );
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