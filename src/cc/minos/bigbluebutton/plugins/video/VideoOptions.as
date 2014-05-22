package cc.minos.bigbluebutton.plugins.video
{
	import flash.media.H264Level;
	import flash.media.H264Profile;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class VideoOptions
	{
		
		public var autoStart:Boolean = false;
		
		public var enableH264:Boolean = true;
		
		public var camKeyFrameInterval:Number = 30;
		
		public var videoWidth:int = 320;
		public var videoHeight:int = 240;
		public var camModeFps:Number = 10;
		
		public var camQualityBandwidth:Number = 0;
		public var videoQuality:Number = 100;
		//public var camQualityPicture:Number = 90;
		
		public var h264Level:String = H264Level.LEVEL_2_1;
		public var h264Profile:String = H264Profile.MAIN;
		
		public var presenterShareOnly:Boolean = true;
		
		public function VideoOptions()
		{
		}
	
	}
}