package cc.minos.bbb.plugins.users
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class PariticipantEvent extends Event
	{
		public static const REFRESH:String = "pariticipantsRefresh";
		public static const JOINED:String = "pariticipantJoined";
		public static const LEFT:String = "pariticipantLeft";
		public static const KICKED:String = "pariticipantKicked";
		public static const PRESENTER_NAME_CHANGE:String = "presenterNameChange";
		public static const SWITCHED_PRESENTER:String = "switchedPresenter";
		
		//
		//public static const STREAM_STARTED:String = "streamStarted";
		//public static const STREAM_STOPED:String = "streamStoped";
		
		public var userID:String;
		
		public function PariticipantEvent( type:String )
		{
			super( type, false, false );
		}
		
		public override function clone():Event
		{
			var event:PariticipantEvent = new PariticipantEvent( type );
			event.userID = userID;
			return event;
		}
	
	}

}