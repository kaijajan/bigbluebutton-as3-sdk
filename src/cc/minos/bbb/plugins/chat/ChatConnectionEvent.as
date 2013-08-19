package cc.minos.bbb.plugins.chat
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class ChatConnectionEvent extends Event
	{
		public static const CONNECT:String = "chatApplicationConnect";
		
		public var success:Boolean;
		
		public function ChatConnectionEvent( type:String )
		{
			super( type, false, false );
		}
		
		public override function clone():Event
		{
			var event:ChatConnectionEvent = new ChatConnectionEvent( type );
			event.success = success;
			return event;
		}
	
	}

}