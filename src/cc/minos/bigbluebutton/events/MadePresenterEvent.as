package cc.minos.bigbluebutton.events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class MadePresenterEvent extends Event
	{
		public static const PRESENTER_NAME_CHANGE:String = "PRESENTER_NAME_CHANGE";
		public static const SWITCH_TO_VIEWER_MODE:String = "VIEWER_MODE";
		public static const SWITCH_TO_PRESENTER_MODE:String = "PRESENTER_MODE";
		
		public var presenterName:String;
		public var assignerBy:String;
		public var userID:String;
		
		public function MadePresenterEvent( type:String )
		{
			super( type, true, false );
		}
	
	}

}