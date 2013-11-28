package cc.minos.bigbluebutton.plugins.chat
{
	import cc.minos.bigbluebutton.events.BigBlueButtonEvent;
	import cc.minos.bigbluebutton.IMessageListener;
	import cc.minos.bigbluebutton.plugins.Plugin;
	import flash.net.registerClassAlias;
	
	/**
	 * 房間群聊應用（非必須）
	 * @author Minos
	 */
	public class ChatPlugin extends Plugin implements IMessageListener
	{
		/** 發送公共信息 */
		private const SEND_PUBLIC_MESSAGE:String = "chat.sendPublicMessage";
		/** 發送私有信息 */
		private const SEND_PRIVATE_MESSAGE:String = "chat.sendPrivateMessage";
		/** 獲取公共聊天歷史*/
		private const GET_MESSAGES:String = "chat.sendPublicChatHistory";
		
		public function ChatPlugin()
		{
			super();
			this.name = "[ChatPlugin]";
			this.shortcut = "chat";
			/** 和服務端java匹配，如果不註冊返回信息的時候無法獲取屬性 */
			registerClassAlias( "org.bigbluebutton.conference.service.chat.ChatMessageVO", ChatMessageVO );
		}
		
		/** 開啟聊天應用 */
		override public function start():void
		{
			bbb.addMessageListener( this );
		}
		
		/** 關閉聊天應用 */
		override public function stop():void
		{
			bbb.removeMessageListener( this );
		}
		
		/**
		 * 發送群聊信息
		 * @param	message
		 */
		public function sendPublicMessage( message:ChatMessageVO ):void
		{
			bbb.send([ SEND_PUBLIC_MESSAGE, responder, message.toObj() ] );
		}
		
		/**
		 * 發送私聊消息
		 * @param	message
		 */
		public function sendPrivateMessage( message:ChatMessageVO ):void
		{
			bbb.send([ SEND_PRIVATE_MESSAGE, responder, message.toObj() ] );
		}
		
		/**
		 * 獲取聊天歷史記錄
		 */
		public function getPublicChatMessages():void
		{
			bbb.send( [GET_MESSAGES, responder] );
		}
		
		/* INTERFACE cc.minos.bigbluebutton.extensions.IMessageListener (信息偵聽器接口) */
		
		public function onMessage( messageName:String, message:Object ):void
		{
			switch ( messageName )
			{
				case "ChatReceivePublicMessageCommand": 
					onChatReceivePublicMessageCommand( message );
					break;
				case "ChatReceivePrivateMessageCommand": 
					onChatReceivePrivateMessageCommand( message );
					break;
				case "ChatRequestMessageHistoryReply": 
					onChatRequestMessageHistoryReply( message );
					break;
				default: 
			}
		}
		
		/**
		 * 記錄處理
		 * @param	message
		 */
		private function onChatRequestMessageHistoryReply( message:Object ):void
		{
			//Console.log( "history message: " + message.count );
			var msgCount:Number = message.count as Number;
			for ( var i:int = 0; i < msgCount; i++ )
			{
				onChatReceivePublicMessageCommand( message.messages[ i ] );
			}
		}
		
		/**
		 * 群聊信息處理
		 * @param	message
		 */
		private function onChatReceivePublicMessageCommand( message:Object ):void
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
			dispatchEvent( chatEvent );
			
			var newEvnet:BigBlueButtonEvent = new BigBlueButtonEvent( BigBlueButtonEvent.NEW_PUBLIC_CHAT );
			newEvnet.parames = message;
			dispatchRawEvent( newEvnet );
		}
		
		/**
		 * 私聊信息處理
		 * @param	message
		 */
		private function onChatReceivePrivateMessageCommand( message:Object ):void
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
			dispatchEvent( chatEvent );
			
			var newEvnet:BigBlueButtonEvent = new BigBlueButtonEvent( BigBlueButtonEvent.NEW_PRIVATE_CHAT );
			newEvnet.parames = message;
			dispatchRawEvent( newEvnet );
		
		}
	}
}