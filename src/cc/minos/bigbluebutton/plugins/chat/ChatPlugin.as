package cc.minos.bigbluebutton.plugins.chat
{
	import cc.minos.bigbluebutton.core.IMessageListener;
	import cc.minos.bigbluebutton.events.ChatMessageEvent;
	import cc.minos.bigbluebutton.models.ChatMessageVO;
	import cc.minos.bigbluebutton.plugins.Plugin;
	import cc.minos.console.Console;
	import flash.net.registerClassAlias;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class ChatPlugin extends Plugin implements IMessageListener, IChatPlugin
	{
		
		private const SEND_PUBLIC_MESSAGE:String = "chat.sendPublicMessage";
		private const SEND_PRIVATE_MESSAGE:String = "chat.sendPrivateMessage";
		private const GET_MESSAGES:String = "chat.sendPublicChatHistory";
		
		public function ChatPlugin()
		{
			super();
			this._name = "[ChatPlugin]";
			this._shortcut = "chat";
			registerClassAlias( "org.bigbluebutton.conference.service.chat.ChatMessageVO", ChatMessageVO );
		}
		
		public function sendPublicMessage( message:ChatMessageVO ):void
		{
			bbb.send( SEND_PUBLIC_MESSAGE, null, message.toObj() );
		}
		
		public function sendPrivateMessage( message:ChatMessageVO ):void
		{
			bbb.send( SEND_PRIVATE_MESSAGE, null, message.toObj() );
		}
		
		public function getPublicChatMessages():void
		{
			Console.log("getting chat history");
			bbb.send( GET_MESSAGES, null );
		}
		
		public function onMessage( messageName:String, message:Object ):void
		{
			switch ( messageName )
			{
				case "ChatRequestMessageHistoryReply": 
					onChatRequestMessageHistoryReply( message );
					break;
				case "ChatReceivePublicMessageCommand": 
					onChatReceivePublicMessageCommand( message );
					break;
				case "ChatReceivePrivateMessageCommand": 
					onChatReceivePrivateMessageCommand( message );
					break;
			}
		}
		
		protected function onChatRequestMessageHistoryReply( message:Object ):void
		{
			var msgCount:Number = message.count as Number;
			for ( var i:int = 0; i < msgCount; i++ )
			{
				onChatReceivePublicMessageCommand( message.messages[ i ] );
			}
		}
		
		protected function onChatReceivePublicMessageCommand( message:Object ):void
		{
			var msg:ChatMessageVO = new ChatMessageVO();
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
			
			var chatEvent:ChatMessageEvent = new ChatMessageEvent( ChatMessageEvent.PUBLIC_CHAT_MESSAGE );
			chatEvent.message = msg;
			dispatchRawEvent( chatEvent );
		}
		
		protected function onChatReceivePrivateMessageCommand( message:Object ):void
		{
			var msg:ChatMessageVO = new ChatMessageVO();
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
			
			var chatEvent:ChatMessageEvent = new ChatMessageEvent( ChatMessageEvent.PRIVATE_CHAT_MESSAGE );
			chatEvent.message = msg;
			dispatchRawEvent( chatEvent );
		}
		
		override public function start():void
		{
			bbb.addMessageListener( this );
			getPublicChatMessages();
		}
		
		override public function stop():void
		{
			bbb.removeMessageListener( this );
		}
	
	}
}