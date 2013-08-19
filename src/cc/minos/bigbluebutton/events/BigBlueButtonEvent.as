
package cc.minos.bigbluebutton.events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class BigBlueButtonEvent extends Event
	{
		public static const USER_LOGGED_IN:String = "successfullyLoggedIn";
		public static const UNKNOWN_REASON:String = "unknownReason";
		public static const CONNECTION_FAILED:String = "connectionFailed";
		public static const CONNECTION_CLOSED:String = "connectionClosed";
		public static const INVALID_APP:String = "invalidApp";
		public static const APP_SHUTDOWN:String = "appShutdown";
		public static const CONNECTION_REJECTED:String = "connectionRejected";
		public static const ASYNC_ERROR:String = "asyncError";
		public static const USER_LOGGED_OUT:String = "userHasLoggedOut";
		
		public var parames:Object = {};
		
		public function BigBlueButtonEvent( type:String )
		{
			super( type, false, false );
		}
	
	}
}