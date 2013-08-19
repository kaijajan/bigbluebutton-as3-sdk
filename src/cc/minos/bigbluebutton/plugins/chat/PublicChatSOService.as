package cc.minos.bigbluebutton.plugins.chat
{
	import cc.minos.bigbluebutton.plugins.ChatPlugin;
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
	public class PublicChatSOService extends EventDispatcher
	{
		private const SO_NAME:String = "chatSO";
		private const SEND_MESSAGE:String = "chat.sendMessage";
		private const GET_MESSAGES:String = "chat.getChatMessages";
		
		private var chatSO:SharedObject;
		private var plugin:ChatPlugin;
		private var isReceivedHistory:Boolean = false;
		
		/**
		 *
		 * @param	plugin
		 */
		public function PublicChatSOService( plugin:ChatPlugin )
		{
			this.plugin = plugin;
			registerClassAlias( "org.bigbluebutton.conference.service.chat.ChatObject", ChatObject );
		}
		
		/**
		 *
		 */
		public function connect():void
		{
			chatSO = SharedObject.getRemote( SO_NAME, plugin.uri, false );
			chatSO.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			chatSO.addEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler );
			chatSO.addEventListener( SyncEvent.SYNC, sharedObjectSyncHandler );
			chatSO.client = this;
			chatSO.connect( plugin.connection );
		}
		
		/**
		 *
		 */
		public function disconnect():void
		{
			if ( chatSO != null )
			{
				chatSO.removeEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
				chatSO.removeEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler );
				chatSO.removeEventListener( SyncEvent.SYNC, sharedObjectSyncHandler );
				chatSO.close();
				chatSO = null;
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
			
			plugin.connection.call( SEND_MESSAGE, new Responder( function( result:Object ):void
				{
					trace( "Successfully sendMessage" );
				}, function( status:Object ):void
				{
					trace( "sendMessage Failed" );
				} ), chatobj );
		}
		
		public function newChatMessage( chatobj:ChatObject ):void
		{
			var event:PublicChatMessageEvent = new PublicChatMessageEvent( PublicChatMessageEvent.PUBLIC_CHAT_MESSAGE_EVENT );
			event.chatObject = chatobj;
			plugin.dispatchEvent( event );
		}
		
		public function getChatMessages():void
		{
			plugin.connection.call( GET_MESSAGES, new Responder( function( result:Object ):void
				{
					trace( "Successfully getChatTranscript" );
					if ( result != null )
					{
						receivedChatHistory( result );
					}
				}, function( status:Object ):void
				{
				} ) );
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
			switch ( statusCode )
			{
				case "NetConnection.Connect.Success": 
					if ( !isReceivedHistory )
					{
						isReceivedHistory = true;
						getChatMessages();
					}
					break;
				default: 
					break;
			}
		}
		
		private function asyncErrorHandler( event:AsyncErrorEvent ):void
		{
			trace( "PresentSO asynchronous error." );
		}
		
		private function sharedObjectSyncHandler( event:SyncEvent ):void
		{
			if ( !isReceivedHistory )
			{
				isReceivedHistory = true;
				getChatMessages();
			}
		}
	}

}