package cc.minos.bigbluebutton
{
	
	import cc.minos.bigbluebutton.model.ConferenceParameters;
	import cc.minos.bigbluebutton.plugins.Plugin;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	/**
	 * BBB服務器接口
	 * @author Minos
	 */
	public interface IBigBlueButton extends IEventDispatcher
	{
		function addMessageListener( listener:IMessageListener ):void;
		function removeMessageListener( listener:IMessageListener ):void;
		function onMessageFromServer( messageName:String, result:Object ):void;
		function send( args:Array ):void;
		
		function addPlugin( plugin:Plugin ):void;
		function removePlugin( shortcut:String ):void;
		function getPlugin( shortcut:String ):Plugin;
		function hasPlugin( shortcut:String ):Boolean;
		
		function set conferenceParameters( conf:ConferenceParameters ):void;
		function get conferenceParameters():ConferenceParameters;
	
	}

}