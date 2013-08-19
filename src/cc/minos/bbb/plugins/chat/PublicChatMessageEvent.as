package cc.minos.bbb.plugins.chat
{
	import flash.events.Event;
	
	public class PublicChatMessageEvent extends Event
	{
		public static const PUBLIC_CHAT_MESSAGE_EVENT:String = 'PUBLIC_CHAT_MESSAGE_EVENT';
		
		public var chatObject:ChatObject;
		
		public function PublicChatMessageEvent( type:String )
		{
			super( type, false, false );
		}
		
		override public function clone():Event
		{
			var event:PublicChatMessageEvent = new PublicChatMessageEvent( type );
			event.chatObject = chatObject;
			return event;
		}
	
	}
}