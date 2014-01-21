package cc.minos.bigbluebutton.playback.steps
{
	import cc.minos.bigbluebutton.playback.events.ZoomEvent;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class ZoomStep extends EventStep
	{
		
		public function ZoomStep( xml:XML = null )
		{
			super( xml );
		}
		
		override protected function sendStepEvent( step:XML ):void
		{
			var ary:Array = step.viewBox.toString().split( " " );
			if ( ary.length < 4 )
				return;
			var stepEvent:ZoomEvent = new ZoomEvent();
			stepEvent.x = ary[ 0 ];
			stepEvent.y = ary[ 1 ];
			stepEvent.width = ary[ 2 ];
			stepEvent.height = ary[ 3 ];
			dispatchEvent( stepEvent );
		}
	
	}

}