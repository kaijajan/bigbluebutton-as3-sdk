package cc.minos.bigbluebutton.core
{
	import cc.minos.bigbluebutton.events.ConnectionFailedEvent;
	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class BaseConnection
	{
		protected var callback:BaseConnectionCallback;
		protected var _uri:String;
		protected var _connection:NetConnection;
		protected var userCommand:Boolean;
		
		public function BaseConnection( callback:BaseConnectionCallback )
		{
			this.callback = callback;
			_connection = new NetConnection();
			_connection.client = callback;
			_connection.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
			_connection.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
			_connection.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			_connection.addEventListener( AsyncErrorEvent.ASYNC_ERROR, onAsyncError );
		
		}
		
		private function onNetStatus( e:NetStatusEvent ):void
		{
			switch ( e.info.code )
			{
				case "NetConnection.Connect.Success": 
					sendConnectionSuccessEvent();
					break;
				case "NetConnection.Connect.Failed": 
					sendConnectionFailedEvent();
					break;
				case "NetConnection.Connect.Closed": 
					sendConnectionFailedEvent( ConnectionFailedEvent.CONNECTION_CLOSED );
					break;
				case "NetConnection.Connect.InvalidApp": 
					sendConnectionFailedEvent( ConnectionFailedEvent.INVALID_APP );
					break;
				case "NetConnection.Connect.AppShutDown": 
					sendConnectionFailedEvent( ConnectionFailedEvent.APP_SHUTDOWN );
					break;
				case "NetConnection.Connect.Rejected": 
					sendConnectionFailedEvent( ConnectionFailedEvent.CONNECTION_REJECTED );
					break;
				case "NetConnection.Connect.NetworkChange": 
					break;
				default: 
					sendConnectionFailedEvent( ConnectionFailedEvent.UNKNOWN_REASON );
					break;
			}
		}
		
		private function onSecurityError( e:SecurityErrorEvent ):void
		{
			sendConnectionFailedEvent( e.text );
		}
		
		private function onIOError( e:IOErrorEvent ):void
		{
			sendConnectionFailedEvent( e.text );
		}
		
		private function onAsyncError( e:AsyncErrorEvent ):void
		{
			sendConnectionFailedEvent( e.text );
		}
		
		public function connect( uri:String, ... params ):void
		{
			_uri = uri;
			try
			{
				trace( "[NetConnection] connecting to: " + _uri );
				_connection.connect.apply( null, new Array( uri ).concat( params ) );
			}
			catch ( er:ArgumentError )
			{
				switch ( er.errorID )
				{
					case 2004:
						
						break;
					default: 
						sendConnectionFailedEvent( ConnectionFailedEvent.UNKNOWN_REASON );
						break;
				}
			}
		}
		
		public function disconnect( userCommand:Boolean ):void
		{
			this.userCommand = userCommand;
			_connection.close();
		}
		
		protected function sendConnectionSuccessEvent( reason:String = "" ):void
		{
			if ( callback != null )
				callback.onSuccess( reason );
		}
		
		protected function sendConnectionFailedEvent( reason:String = "" ):void
		{
			if ( callback != null )
				callback.onFailed( reason );
		}
		
		///////////////////////
		// GETTERS/SETTERS
		///////////////////////
		
		public function get uri():String
		{
			return _uri;
		}
		
		public function get connection():NetConnection
		{
			return _connection;
		}
	
	}
}