package cc.minos.bigbluebutton.plugins.video
{
	import flash.events.Event;
	
	public class ConnectedEvent extends Event
	{
		public static const VIDEO_CONNECTED:String = "videoConnected";
		
		public function ConnectedEvent( type:String )
		{
			super( type, false, false );
		}
	}
}