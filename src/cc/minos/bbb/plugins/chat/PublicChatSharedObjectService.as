package cc.minos.bbb.plugins.chat
{
	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.SyncEvent;
	import flash.net.NetConnection;
	import flash.net.registerClassAlias;
	import flash.net.Responder;
	import flash.net.SharedObject;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class PublicChatSharedObjectService extends EventDispatcher
	{
		private var SO_NAME:String = "chatSO";
		private var chatSO:SharedObject;
		private var plugin:ChatPlugin;
		
		public function PublicChatSharedObjectService( plugin:ChatPlugin )
		{
			this.plugin = plugin;
			registerClassAlias( "org.bigbluebutton.conference.service.chat.ChatObject", ChatObject );
		}
		
		public function join():void
		{
			chatSO = SharedObject.getRemote( "chatSO", plugin.uri, false );
			chatSO.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			chatSO.addEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler );
			chatSO.addEventListener( SyncEvent.SYNC, sharedObjectSyncHandler );
			chatSO.client = this;
			chatSO.connect( plugin.connection );
		}
		
		public function leave():void
		{
			if ( chatSO != null )
			{
				chatSO.close();
			}
		}
		
		public function sendMessage( message:String, username:String, color:String, time:String, language:String, userid:String ):void
		{
			
			var chatobj:ChatObject = new ChatObject();
			chatobj.message = message;
			chatobj.username = username;
			chatobj.color = color;
			chatobj.time = time;
			chatobj.language = language;
			chatobj.userid = userid;
			
			var nc:NetConnection = plugin.connection;
			nc.call( "chat.sendMessage", // Remote function name
				new Responder( 
				// On successful result
				function( result:Object ):void
				{
					trace( "Successfully sendMessage" );
				}, 
				// status - On error occurred
				function( status:Object ):void
				{
					trace( "sendMessage Failed" );
				} ), //new Responder
				chatobj ); //_netConnection.call
		}
		
		public function newChatMessage( chatobj:ChatObject ):void
		{
			var event:PublicChatMessageEvent = new PublicChatMessageEvent( PublicChatMessageEvent.PUBLIC_CHAT_MESSAGE_EVENT );
			event.chatObject = chatobj;
			dispatchEvent( event );
		}
		
		public function getChatTranscript():void
		{
			var nc:NetConnection = plugin.connection;
			nc.call( "chat.getChatMessages", // Remote function name
				new Responder( 
				// On successful result
				function( result:Object ):void
				{
					trace( "Successfully getChatTranscript" );
					if ( result != null )
					{
						receivedChatHistory( result );
					}
				}, 
				// status - On error occurred
				function( status:Object ):void
				{
				} ) //new Responder
				); //_netConnection.call		
		}
		
		private function receivedChatHistory( result:Object ):void
		{
			if ( result == null )
				return;
			
			var messages:Array = result as Array;
			trace( "receivedChatHistory: " + messages.length );
			for ( var i:int = 0; i < messages.length; i++ )
			{
				newChatMessage( messages[ i ] as ChatObject );
			}
		}
		
		private function netStatusHandler( e:NetStatusEvent ):void
		{
			var statusCode:String = e.info.code;
			
			var connEvent:ChatConnectionEvent = new ChatConnectionEvent( ChatConnectionEvent.CONNECT );
			switch ( statusCode )
			{
				case "NetConnection.Connect.Success": 
					connEvent.success = true;
					break;
				default: 
					connEvent.success = false;
					break;
			}
			dispatchEvent( connEvent );
		}
		
		private function asyncErrorHandler( event:AsyncErrorEvent ):void
		{
			trace( "PresentSO asynchronous error." );
		}
		
		private function sharedObjectSyncHandler( event:SyncEvent ):void
		{
			var connEvent:ChatConnectionEvent = new ChatConnectionEvent( ChatConnectionEvent.CONNECT );
			connEvent.success = true;
			trace( "Dispatching NET CONNECTION SUCCESS" );
			dispatchEvent( connEvent );
		}
	}

}