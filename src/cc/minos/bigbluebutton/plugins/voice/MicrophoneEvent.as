package cc.minos.bigbluebutton.plugins.voice
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class MicrophoneEvent extends Event
	{
		public static const MIC_ACCESS_DENIED_EVENT:String = "micAccessDenied";
		public static const MIC_ACCESS_ALLOWED_EVENT:String = "micAccessAllowed";
		public static const MICROPHONE_UNAVAIL_EVENT:String = 'micUnavail';
		
		public function MicrophoneEvent( type:String )
		{
			super( type, false, false );
		}
		
		public override function clone():Event
		{
			return new MicrophoneEvent( type );
		}
	
	}

}