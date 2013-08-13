package cc.minos.bbb.plugins.users
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class ListenerEvent extends Event
	{
		public static const USER_VOICE_JOINED:String = 'user voice joined event';
		public static const USER_VOICE_MUTED:String = "user voice muted event";
		public static const USER_VOICE_LOCKED:String = "user voice locked event";
		public static const USER_VOICE_LEFT:String = "user voice left event";
		public static const USER_VOICE_TALKING:String = "user voice talking event";
		
		public static const ROOM_MUTE_STATE:String = "roomMuteState";
		
		public var userid:String;
		public var mute:Boolean;
		public var lock:Boolean;
		
		public function ListenerEvent( type:String )
		{
			super( type, false, false );
		}
		
		override public function clone():Event
		{
			var event:ListenerEvent = new ListenerEvent( type );
			event.userid = userid;
			event.mute = mute;
			event.lock = lock;
			return event;
		}
	
	}

}