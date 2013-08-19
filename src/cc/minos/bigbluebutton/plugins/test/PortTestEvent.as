
package cc.minos.bigbluebutton.plugins.test
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class PortTestEvent extends Event
	{
		
		public static const PORT_TEST_SUCCESS:String = "portTestSuccess";
		public static const PORT_TEST_FAILED:String = "portTestFailed";
		public static const PORT_TEST_UPDATE:String = "portTestUpdate";
		
		public var protocol:String;
		public var host:String;
		public var application:String;
		public var port:String;
		
		public function PortTestEvent( type:String ):void
		{
			super( type, false, false );
		}
		
		override public function clone():Event
		{
			var event:PortTestEvent = new PortTestEvent( this.type );
			event.host = this.host;
			event.protocol = this.protocol;
			event.application = this.application;
			event.port = this.port;
			return event;
		}
	}
}