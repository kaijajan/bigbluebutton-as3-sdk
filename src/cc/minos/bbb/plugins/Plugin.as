
package cc.minos.bbb.plugins
{
	import cc.minos.bbb.BigBlueButton;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class Plugin extends EventDispatcher
	{
		
		protected var bbb:BigBlueButton = null;
		public var shortcut:String = null;
		public var name:String = "[BigBlueButton Plugin]";
		public var application:String = "bigbluebutton";
		
		public function Plugin()
		{
		}
		
		public function setInstance( bbb:BigBlueButton ):void
		{
			this.bbb = bbb;
		}
		
		public function init():void
		{
			//TODO
		}
		
		public function start():void
		{
		}
		
		public function stop():void
		{
		}
		
		///////////////////////
		// GETTERS/SETTERS
		///////////////////////
		
		public function get uri():String
		{
			return bbb.conferenceParameters.protocol + "://" + bbb.conferenceParameters.host + "/" + application;
		}
	
	}
}