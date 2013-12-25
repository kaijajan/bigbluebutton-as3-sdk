package cc.minos.bigbluebutton.plugins
{
	import cc.minos.bigbluebutton.core.IBigBlueButtonConnection;
	import flash.events.Event;
	import flash.net.NetConnection;
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IPlugin
	{
		
		function setup( bbb:IBigBlueButtonConnection ):void;
		function start():void;
		function stop():void;
		function init():void;
		function dispatchRawEvent( e:Event ):Boolean;
		
		function get uri():String;
		function get connection():NetConnection;
		function get userID():String;
		function get username():String;
		function get presenter():Boolean;
		function get name():String;
		function get application():String;
		function get shortcut():String;
	
	}
}