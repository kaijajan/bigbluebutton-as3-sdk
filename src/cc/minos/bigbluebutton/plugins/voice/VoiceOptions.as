
package cc.minos.bigbluebutton.plugins.voice
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public class VoiceOptions
	{
		
		public var enabledEchoCancel:Boolean = true;
		public var skipCheck:Boolean = true;
		public var autoJoin:Boolean = false;
		public var muteAll:Boolean = false;
		
		public var codec:String = "SPEEX";
		
		public function VoiceOptions()
		{
		}
	
	}
}