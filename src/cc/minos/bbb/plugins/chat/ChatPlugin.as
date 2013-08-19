
package cc.minos.bbb.plugins.chat
{
	import cc.minos.bbb.IMessageListener;
	import cc.minos.bbb.plugins.chat.Message;
	import cc.minos.bbb.plugins.Plugin;
	import flash.net.NetConnection;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class ChatPlugin extends Plugin implements IMessageListener
	{
		
		private var publicChatSOS:PublicChatSharedObjectService;
		
		public function ChatPlugin()
		{
			super();
			this.name = "[ChatPlugin]";
			this.shortcut = "chat";
		}
		
		override public function init():void
		{
			bbb.addMessageListener( this );
			publicChatSOS = new PublicChatSharedObjectService( this );
			publicChatSOS.addEventListener( ChatConnectionEvent.CONNECT, onChatConnection );
			publicChatSOS.addEventListener( PublicChatMessageEvent.PUBLIC_CHAT_MESSAGE_EVENT, onChatMessage );
		
		}
		
		private function onChatMessage( e:PublicChatMessageEvent ):void
		{
			dispatchEvent( e );
		}
		
		private function onChatConnection( e:ChatConnectionEvent ):void
		{
			if ( e.success )
			{
				publicChatSOS.getChatTranscript();
			}
			else
			{
				trace( "chat application public shared object error." );
			}
		}
		
		override public function start():void
		{
			publicChatSOS.join();
		}
		
		override public function get uri():String
		{
			var _uri:String = super.uri + "/" + bbb.conferenceParameters.room;
			return _uri;
		}
		
		public function get connection():NetConnection
		{
			return bbb.conferenceParameters.connection;
		}
		
		public function sendMessage( message:String, username:String, color:String, time:String, language:String, userid:String ):void
		{
			publicChatSOS.sendMessage( message, username, color, time, language, userid );
		}
		
		public function sendPublicMessage( message:Message ):void
		{
			bbb.sendMessage( "chat.sendPublicMessage", function( result:String ):void
				{ // On successful result
					trace( result );
				}, function( status:String ):void
				{ // status - On error occurred
					trace( status );
				}, message.toObj() );
		}
		
		public function getPublicChatMessages():void
		{
			bbb.sendMessage( "chat.sendPublicChatHistory", function( result:String ):void
				{ // On successful result
					trace( result );
				}, function( status:String ):void
				{ // status - On error occurred
					trace( status );
				} );
		}
		
		public function sendPrivateMessage( message:Message ):void
		{
			bbb.sendMessage( "chat.sendPrivateMessage", function( result:String ):void
				{ // On successful result
					trace( result );
				}, function( status:String ):void
				{ // status - On error occurred
					trace( status );
				}, message.toObj() );
		}
		
		/* INTERFACE cc.minos.bbb.IMessageListener */
		
		public function onMessage( messageName:String, message:Object ):void
		{
			switch ( messageName )
			{
				case "ChatReceivePublicMessageCommand": 
					handleChatReceivePublicMessageCommand( message );
					break;
				case "ChatReceivePrivateMessageCommand": 
					handleChatReceivePrivateMessageCommand( message );
					break;
				case "ChatRequestMessageHistoryReply": 
					handleChatRequestMessageHistoryReply( message );
					break;
				default: 
			}
		}
		
		/**
		 * 信息历史处理
		 * @param	message
		 */
		private function handleChatRequestMessageHistoryReply( message:Object ):void
		{
			var msgCount:Number = message.count as Number;
			for ( var i:int = 0; i < msgCount; i++ )
			{
				handleChatReceivePublicMessageCommand( message.messages[ i ] );
			}
		}
		
		/**
		 * 公共消息处理
		 * @param	message
		 */
		private function handleChatReceivePublicMessageCommand( message:Object ):void
		{
			var msg:Message = new Message();
			msg.chatType = message.chatType;
			msg.fromUserID = message.fromUserID;
			msg.fromUsername = message.fromUsername;
			msg.fromColor = message.fromColor;
			msg.fromLang = message.fromLang;
			msg.fromTime = message.fromTime;
			msg.fromTimezoneOffset = message.fromTimezoneOffset;
			msg.toUserID = message.toUserID;
			msg.toUsername = message.toUsername;
			msg.message = message.message;
		
		/*var pcEvent:PublicChatMessageEvent = new PublicChatMessageEvent( PublicChatMessageEvent.PUBLIC_CHAT_MESSAGE_EVENT );
		   pcEvent.message = msg;
		 dispatchEvent( pcEvent );*/
		}
		
		/**
		 * 私信处理
		 * @param	message
		 */
		private function handleChatReceivePrivateMessageCommand( message:Object ):void
		{
			var msg:Message = new Message();
			msg.chatType = message.chatType;
			msg.fromUserID = message.fromUserID;
			msg.fromUsername = message.fromUsername;
			msg.fromColor = message.fromColor;
			msg.fromLang = message.fromLang;
			msg.fromTime = message.fromTime;
			msg.fromTimezoneOffset = message.fromTimezoneOffset;
			msg.toUserID = message.toUserID;
			msg.toUsername = message.toUsername;
			msg.message = message.message;
		
		/*var pcEvent:PrivateChatMessageEvent = new PrivateChatMessageEvent( PrivateChatMessageEvent.PRIVATE_CHAT_MESSAGE_EVENT );
		   pcEvent.message = msg;
		 dispatchEvent( pcEvent );*/
		}
	}
}