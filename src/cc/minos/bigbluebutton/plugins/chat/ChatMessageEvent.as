package cc.minos.bigbluebutton.plugins.chat
{
	import flash.events.Event;
	
	public class ChatMessageEvent extends Event
	{
		/** 公共信息事件 */
		public static const PUBLIC_CHAT_MESSAGE:String = 'publicChatMessage';
		/** 私有信息事件 */
		public static const PRIVATE_CHAT_MESSAGE:String = 'privateChatMessage';
		
		public var message:ChatMessageVO;
		
		public function ChatMessageEvent( type:String )
		{
			super( type, false, false );
		}
		
		override public function clone():Event
		{
			var event:ChatMessageEvent = new ChatMessageEvent( type );
			event.message = message;
			return event;
		}
	}
}