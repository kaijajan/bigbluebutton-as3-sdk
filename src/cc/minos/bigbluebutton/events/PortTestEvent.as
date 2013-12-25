package cc.minos.bigbluebutton.events
{
	import flash.events.Event;
	
	/**
	 * 端口測試事件
	 * @author Minos
	 */
	public class PortTestEvent extends Event
	{
		/** 端口測試成功 */
		public static const PORT_TEST_SUCCESS:String = "portTestSuccess";
		/** 端口測試失敗 */
		public static const PORT_TEST_FAILED:String = "portTestFailed";
		
		/** 端口測試數據更新 */
		//public static const PORT_TEST_UPDATE:String = "portTestUpdate";
		
		/** 協議
		   public var protocol:String;
		   public var host:String;
		   public var application:String;
		   public var port:String;
		 */
		
		public function PortTestEvent( type:String ):void
		{
			super( type, false, false );
		}
		
		/**
		 * 複製
		 * @return	返回端口測試事件PortTestEvent
		 */
		override public function clone():Event
		{
			var event:PortTestEvent = new PortTestEvent( this.type );
			/*event.host = this.host;
			   event.protocol = this.protocol;
			   event.application = this.application;
			 event.port = this.port;*/
			return event;
		}
	}
}