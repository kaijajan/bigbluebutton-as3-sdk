package cc.minos.bbb.events
{
	import flash.events.Event;
	
	public class StreamStartedEvent extends Event
	{
		public static const STREAM_STARTED:String = "STREAM_STARTED";
		
		public var user:String;
		public var stream:String;
		public var userID:String
		
		public function StreamStartedEvent( userID:String, user:String, stream:String )
		{
			this.userID = userID;
			this.user = user;
			this.stream = stream;
			super( STREAM_STARTED, true, false );
		}
	
	}
}