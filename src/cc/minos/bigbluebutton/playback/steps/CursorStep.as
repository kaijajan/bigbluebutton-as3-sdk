package cc.minos.bigbluebutton.playback.steps
{
	import cc.minos.bigbluebutton.playback.events.CursorEvent;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class CursorStep extends EventStep
	{
		
		public function CursorStep( xml:XML = null )
		{
			super( xml );
		}
		
		override protected function sendStepEvent( step:XML ):void
		{
			var pos:Array = step.cursor.toString().split( " " );
			if ( pos.length < 2 )
				return;
			var stepEvent:CursorEvent = new CursorEvent();
			stepEvent.x = pos[ 0 ];
			stepEvent.y = pos[ 1 ];
			dispatchEvent( stepEvent );
		}
	
	}

}