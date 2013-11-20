package cc.minos.bigbluebutton.plugins.video
{
	import flash.events.Event;
	import flash.net.NetConnection;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class VideoEvent extends Event
	{
		public static const VIDEO_APPLICATION_CONNECTED:String = "videoApplicationConnected";
		public static const VIDEO_APPLICATION_CLOSED:String = "videoApplicationClosed";
		public static const CAMERA_NOT_FOUND:String = "cameraNotFound";
		public static const PRESENTER_SHARE_ONLY:String = "presenterShareOnly";
		
		public var connection:NetConnection;
		
		//public var streamName:String;
		
		public function VideoEvent( type:String )
		{
			super( type, false, false );
		}
		
		override public function clone():Event
		{
			var evt:VideoEvent = new VideoEvent( type );
			evt.connection = connection;
			return evt;
		}
	
	}

}