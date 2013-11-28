package cc.minos.bigbluebutton.plugins
{
	import cc.minos.bigbluebutton.IBigBlueButton;
	import cc.minos.bigbluebutton.model.BBBUser;
	import cc.minos.console.Console;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	/**
	 * 應用基類
	 * @author Minos
	 */
	public class Plugin extends EventDispatcher
	{
		/** 服务器 */
		protected var bbb:IBigBlueButton = null;
		/** 應用短名稱 */
		public var shortcut:String = null;
		/** 應用標識 */
		public var name:String = "[BigBlueButton Plugin]";
		/** 應用地址（默認為bigbluebutton） */
		public var application:String = "bigbluebutton";
		
		protected var responder:Responder;
		
		public function Plugin()
		{
			responder = new Responder( function( result:Boolean ):void
				{
				}, function( status:Object ):void
				{
				} )
		}
		
		/**
		 * 設置BBB主類
		 * @param	bbb
		 */
		public function setup( bbb:IBigBlueButton ):void
		{
			this.bbb = bbb;
			init();
		}
		
		/** 初始化應用 */
		protected function init():void
		{
			//TODO
		}
		
		/** 開啟應用，在添加時調用 */
		public function start():void
		{
			//TODO
		}
		
		/** 停止應用，在移除時調用 */
		public function stop():void
		{
			//TODO
		}
		
		/**
		 * 應用服務器地址（默認）
		 */
		public function get uri():String
		{
			return bbb.conferenceParameters.protocol + "://" + bbb.conferenceParameters.host + "/" + application;
		}
		
		/**
		 * 連接
		 */
		public function get connection():NetConnection
		{
			return bbb.conferenceParameters.connection;
		}
		
		/**
		 * 
		 */
		public function get userID():String
		{
			return bbb.conferenceParameters.userID;
		}
		
		/**
		 * 
		 */
		public function get username():String
		{
			return bbb.conferenceParameters.username;
		}
		
		/**
		 * 是否演講者
		 */
		public function get presenter():Boolean
		{
			if ( bbb.hasPlugin( "users" ) )
				return bbb.getPlugin("users")['getMe']().presenter;
			return false;
		}
		
		public function dispatchRawEvent(e:Event):Boolean 
		{
			return bbb.dispatchEvent( e );
		}
	
	}
}