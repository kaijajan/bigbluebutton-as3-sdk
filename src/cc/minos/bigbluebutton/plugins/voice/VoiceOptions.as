package cc.minos.bigbluebutton.plugins.voice
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public class VoiceOptions
	{
		/** 回音抑制 */
		public var enabledEchoCancel:Boolean = true;
		/** 是否跳開麥克風測試 */
		public var skipCheck:Boolean = true;
		/** 自動加入 */
		public var autoJoin:Boolean = false;
		/** */
		public var muteAll:Boolean = false;
		
		public function VoiceOptions()
		{
		}
	
	}

}