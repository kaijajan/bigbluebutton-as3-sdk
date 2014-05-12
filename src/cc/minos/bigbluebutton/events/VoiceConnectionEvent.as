package cc.minos.bigbluebutton.events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class VoiceConnectionEvent extends Event
	{
		public static const SUCCESS:String = "voiceConnectionSuccess";
		public static const FAILED:String = "voiceConnectionFailed";
		
		public var reason:String;
		
		public function VoiceConnectionEvent( type:String )
		{
			super( type, true, false );
		}
		
		public override function clone():Event
		{
			var vEvent:VoiceConnectionEvent = new VoiceConnectionEvent( type );
			vEvent.reason = reason;
			return vEvent;
		}
	
	}

}