package cc.minos.bigbluebutton.playback.events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class CursorEvent extends Event
	{
		public static const UPDATE:String = "playback.cursor";
		
		public var x:Number;
		public var y:Number;
		
		public function CursorEvent()
		{
			super( UPDATE, true, false );
		}
		
		public override function clone():Event
		{
			var cE:CursorEvent = new CursorEvent();
			cE.x = x;
			cE.y = y;
			return cE;
		}
	
	}

}