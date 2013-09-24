package cc.minos.bigbluebutton.plugins.voice
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class ConnectionEvent extends Event
	{
		
		/** */
		public static const CALL_CONNECTED:String = 'callConnected';
		/** */
		public static const CALL_DISCONNECTED:String = 'callDisconnected';
		
		public var publishStreamName:String;
		public var playStreamName:String;
		public var codec:String;
		
		public function ConnectionEvent( type:String )
		{
			super( type, false, false );
		}
		
		public override function clone():Event
		{
			var evt:ConnectionEvent = new ConnectionEvent( type );
			evt.publishStreamName = publishStreamName;
			evt.playStreamName = playStreamName;
			evt.codec = codec;
			return evt;
		}
	
	}

}