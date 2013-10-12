package cc.minos.bigbluebutton.events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class BigBlueButtonEvent extends Event
	{
		/** 用戶登錄 */
		public static const USER_LOGGED_IN:String = "userLoggedIn";
		/** 用戶登出 */
		public static const USER_LOGGED_OUT:String = "userLoggedOut";
		/** 未知錯誤 */
		public static const UNKNOWN_REASON:String = "unknownReason";
		/** 連接失敗 */
		public static const CONNECTION_FAILED:String = "connectionFailed";
		/** 連接關閉 */
		public static const CONNECTION_CLOSED:String = "connectionClosed";
		/** 無效服務 */
		public static const INVALID_APP:String = "invalidApp";
		/** 服務關閉 */
		public static const APP_SHUTDOWN:String = "appShutdown";
		/** 連接被拒絕 */
		public static const CONNECTION_REJECTED:String = "connectionRejected";
		/** 同步錯誤 */
		public static const ASYNC_ERROR:String = "asyncError";
		/** 私有信息 */
		public static const NEW_PRIVATE_CHAT:String = "newPrivateChat";
		/** 公共信息 */
		public static const NEW_PUBLIC_CHAT:String = "newPublicChat";
		
		/** */
		public static const SHOW_MIC_SETTINGS:String = "showMicSettings";
		/** */
		public static const SHOW_WEBCAM_SETTINGS:String = "showWebcamSettings";
		
		public var parames:Object = {};
		
		public function BigBlueButtonEvent( type:String )
		{
			super( type, false, false );
		}
		
		override public function clone():Event
		{
			var event:BigBlueButtonEvent = new BigBlueButtonEvent( type );
			event.parames = parames;
			return event;
		}
	
	}
}