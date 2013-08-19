
package cc.minos.bigbluebutton.plugins
{
	import cc.minos.bigbluebutton.BigBlueButton;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.NetConnection;
	
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
		
		public function setup( bbb:BigBlueButton ):void
		{
			this.bbb = bbb;
		}
		
		public function init():void
		{
			//TODO
		}
		
		public function start():void
		{
			//TODO
		}
		
		public function stop():void
		{
			//TODO
		}
		
		public function get uri():String
		{
			return bbb.conferenceParameters.protocol + "://" + bbb.conferenceParameters.host + "/" + application;
		}
		
		public function get connection():NetConnection
		{
			return bbb.conferenceParameters.connection;
		}
		
		public function dispatchRawEvent( e:Event ):void
		{
			bbb.dispatchEvent( e );
		}
	}
}