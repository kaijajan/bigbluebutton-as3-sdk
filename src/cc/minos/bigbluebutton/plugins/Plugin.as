package cc.minos.bigbluebutton.plugins
{
	import cc.minos.bigbluebutton.core.IBigBlueButtonConnection;
	import cc.minos.bigbluebutton.plugins.IPlugin;
	import flash.events.Event;
	import flash.net.NetConnection;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class Plugin implements IPlugin
	{
		
		protected var bbb:IBigBlueButtonConnection;
		protected var _shortcut:String;
		protected var _name:String;
		protected var _application:String = "bigbluebutton";
		
		public function Plugin()
		{
		}
		
		/**
		 *
		
		 */
		public function setup( bbb:IBigBlueButtonConnection ):void
		{
			this.bbb = bbb;
			init();
		}
		
		public function start():void
		{
		}
		
		public function stop():void
		{
		}
		
		/**
		 *
		
		 */
		public function dispatchRawEvent( e:Event ):Boolean
		{
			return bbb.dispatchEvent( e );
		}
		
		public function init():void
		{
		}
		
		public function get shortcut():String
		{
			return _shortcut;
		}
		
		public function get uri():String
		{
			return "rtmp://" + bbb.config.host + "/" + application;
		}
		
		public function get connection():NetConnection
		{
			return bbb.connection;
		}
		
		public function get userID():String
		{
			return bbb.userID;
		}
		
		public function get username():String
		{
			return bbb.conferenceParameters.username;
		}
		
		public function get presenter():Boolean
		{
			if ( bbb.hasPlugin( "users" ) )
			{
				return bbb.getPlugin( "users" )[ "usersList" ].me.presenter;
			}
			return false;
		}
		
		public function get application():String
		{
			return _application;
		}
		
		public function get name():String
		{
			return _name;
		}
	
	}
}