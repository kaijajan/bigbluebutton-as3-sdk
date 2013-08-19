package cc.minos.bbb.plugins.chat
{
	import flash.events.Event;
	
	public class PrivateChatMessageEvent extends Event
	{
		
		public static const PRIVATE_CHAT_MESSAGE_EVENT:String = 'PRIVATE_CHAT_MESSAGE_EVENT';
		
		public var message:Message;
		
		public function PrivateChatMessageEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
	
	}
}