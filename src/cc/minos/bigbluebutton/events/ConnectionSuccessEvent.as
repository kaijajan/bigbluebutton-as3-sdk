package cc.minos.bigbluebutton.events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class ConnectionSuccessEvent extends Event
	{
		static public const SUCCESS:String = "connectionSuccess";
		
		public function ConnectionSuccessEvent()
		{
			super( SUCCESS, false, false );
		}
		
		public override function clone():Event
		{
			return new ConnectionSuccessEvent();
		}
	
	}

}