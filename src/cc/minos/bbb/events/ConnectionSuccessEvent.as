package cc.minos.bbb.events
{
	import cc.minos.bbb.ConferenceParameters;
	import flash.events.Event;
	
	public class ConnectionSuccessEvent extends Event
	{
		public static const USER_LOGGED_IN:String = "successfullyLoggedIn";
		
		public function ConnectionSuccessEvent( type:String )
		{
			super( type, false, false );
		}
	}
}