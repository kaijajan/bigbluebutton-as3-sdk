package cc.minos.bbb.plugins.video
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public class VideoOptions
	{
		public var videoQuality:Number = 100;
		public var resolutions:String = "320x240,640x480,1280x720";
		public var camKeyFrameInterval:Number = 30;
		public var camModeFps:Number = 10;
		public var camQualityBandwidth:Number = 0;
		public var camQualityPicture:Number = 90;
		public var enableH264:Boolean = true;
		public var h264Level:String = "2.1";
		public var h264Profile:String = 'main';
		
		public function VideoOptions()
		{
		}
	
	}

}