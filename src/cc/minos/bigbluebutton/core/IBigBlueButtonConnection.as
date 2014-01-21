package cc.minos.bigbluebutton.core
{
	import cc.minos.bigbluebutton.models.IConferenceParameters;
	import cc.minos.bigbluebutton.models.IConfig;
	import cc.minos.bigbluebutton.plugins.IPlugin;
	import flash.events.IEventDispatcher;
	import flash.net.NetConnection;
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IBigBlueButtonConnection extends IEventDispatcher
	{
		
		///////////////////////
		// METHODS
		///////////////////////
		
		function connect( params:IConferenceParameters, tunnel:Boolean = false ):void;
		function disconnect( userCommand:Boolean ):void;
		function send( cmd:String, ... params ):void;
		/**
		 *
		
		 */
		function onMessageFromServer( messageName:String, message:Object ):void;
		/**
		 *
		
		 */
		function addMessageListener( listener:IMessageListener ):void;
		/**
		 *
		
		 */
		function removeMessageListener( listener:IMessageListener ):void;
		
		/**
		 *
		
		 */
		function addPlugin( plugin:IPlugin ):void;
		/**
		 *
		
		 */
		function removePlugin( shortcut:String ):void;
		/**
		 *
		
		 */
		function getPlugin( shortcut:String ):IPlugin;
		/**
		 *
		
		 */
		function hasPlugin( shortcut:String ):Boolean;
		
		function startAllPlugin():void
		///////////////////////
		// GETTERS/SETTERS
		///////////////////////
		
		function get userID():String;
		function get connection():NetConnection;
		function get conferenceParameters():IConferenceParameters;
		function get config():IConfig;
	
	}
}