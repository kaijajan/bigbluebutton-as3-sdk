package cc.minos.bigbluebutton.plugins
{
	import cc.minos.bigbluebutton.BigBlueButton;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.NetConnection;
	
	/**
	 * 應用基類
	 * @author Minos
	 */
	public class Plugin extends EventDispatcher
	{
		/** 主類引用 */
		protected var bbb:BigBlueButton = null;
		/** 應用短名稱 */
		public var shortcut:String = null;
		/** 應用標識 */
		public var name:String = "[BigBlueButton Plugin]";
		/** 應用地址（默認為bigbluebutton） */
		public var application:String = "bigbluebutton";
		
		public function Plugin()
		{
		}
		
		/**
		 * 設置BBB主類
		 * @param	bbb
		 */
		public function setup( bbb:BigBlueButton ):void
		{
			this.bbb = bbb;
		}
		
		/** 初始化應用 */
		public function init():void
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
		 * 網絡連接
		 */
		public function get connection():NetConnection
		{
			return bbb.conferenceParameters.connection;
		}
		
		/**
		 *
		 * @param	e
		 */
		public function dispatchRawEvent( e:Event ):void
		{
			bbb.dispatchEvent( e );
		}
	}
}