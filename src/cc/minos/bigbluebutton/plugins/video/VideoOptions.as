package cc.minos.bigbluebutton.plugins.video
{
	import flash.media.H264Level;
	import flash.media.H264Profile;
	
	/**
	 * @author Minos
	 */
	public class VideoOptions
	{
		//public var resolutions:String = "320x240,640x480,1280x720";
		/** 視頻格式 */
		public var enableH264:Boolean = true;
		
		public var camKeyFrameInterval:Number = 30;
		
		/** 視頻寬 */
		public var videoWidth:int = 320;
		/** 視頻高 */
		public var videoHeight:int = 240;
		/** 幀數 */
		public var camModeFps:Number = 10;
		
		public var camQualityBandwidth:Number = 0;
		public var videoQuality:Number = 100;
		//public var camQualityPicture:Number = 90;
		
		public var h264Level:String = H264Level.LEVEL_2_1;
		public var h264Profile:String = H264Profile.MAIN;
		
		public function VideoOptions()
		{
		}
	
	}

}