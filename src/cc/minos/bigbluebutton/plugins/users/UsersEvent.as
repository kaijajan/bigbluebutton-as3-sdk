package cc.minos.bigbluebutton.plugins.users
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class UsersEvent extends Event
	{
		public static const REFRESH:String = "pariticipantsRefresh";
		public static const JOINED:String = "pariticipantJoined";
		public static const LEFT:String = "pariticipantLeft";
		public static const KICKED:String = "pariticipantKicked";
		public static const PRESENTER_NAME_CHANGE:String = "presenterNameChange";
		public static const SWITCHED_PRESENTER:String = "switchedPresenter";
		
		public static const USER_VOICE_JOINED:String = 'userVoiceJoined';
		public static const USER_VOICE_MUTED:String = "userVoiceMuted";
		public static const USER_VOICE_LOCKED:String = "userVoiceLocked";
		public static const USER_VOICE_LEFT:String = "userVoiceLeft";
		public static const USER_VOICE_TALKING:String = "userVoiceTalking";
		
		public static const ROOM_MUTE_STATE:String = "roomMuteState";
		
		public var userID:String;
		public var mute:Boolean;
		
		public function UsersEvent( type:String )
		{
			super( type, false, false );
		}
		
		override public function clone():Event
		{
			var event:UsersEvent = new UsersEvent( type );
			event.userID = userID;
			return event;
		}
	}

}