
package cc.minos.bbb.events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class BigBlueButtonEvent extends Event
	{
		
		public var message:String;
		
		public function BigBlueButtonEvent( type:String )
		{
			super( type );
		}
	
	}
}