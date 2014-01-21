package cc.minos.bigbluebutton.playback.steps
{
	import cc.minos.bigbluebutton.playback.events.ChatMessageEvent;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class ChatStep extends EventStep
	{
		
		public function ChatStep( xml:XML = null )
		{
			super( xml );
			eventNode = "chattimeline";
			timeNode = "in";
		}
		
		override protected function sendStepEvent( step:XML ):void
		{
			var messageEvent:ChatMessageEvent = new ChatMessageEvent();
			messageEvent.direction = step.@direction;
			messageEvent.name = step.@name;
			messageEvent.message = step.@message;
			dispatchEvent( messageEvent );
		}
	
	}

}