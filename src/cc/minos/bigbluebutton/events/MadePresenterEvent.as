package cc.minos.bigbluebutton.events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class MadePresenterEvent extends Event
	{
		/** 演講者切換 */
		public static const PRESENTER_NAME_CHANGE:String = "presenterNameChange";
		/** 演講者 */
		public static const SWITCH_TO_VIEWER_MODE:String = "switchToViewerMode";
		/** 瀏覽者 */
		public static const SWITCH_TO_PRESENTER_MODE:String = "switchToPresenterMode";
		
		/** */
		public var presenterName:String;
		/** */
		public var assignerBy:String;
		/** */
		public var userID:String;
		
		public function MadePresenterEvent( type:String )
		{
			super( type, true, false );
		}
		
		override public function clone():Event
		{
			var event:MadePresenterEvent = new MadePresenterEvent( type );
			event.presenterName = presenterName;
			event.assignerBy = assignerBy;
			event.userID = userID;
			return event;
		}
	}

}