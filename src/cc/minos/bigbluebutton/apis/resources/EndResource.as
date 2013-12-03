package cc.minos.bigbluebutton.apis.resources
{
	import cc.minos.bigbluebutton.apis.responses.EndResponse;
	
	/**
	 * Ends meeting.
	 * @author Minos
	 */
	public class EndResource extends Resource
	{
		public static const CALL_NAME:String = "end";
		
		protected var _password:String;
		
		public function EndResource( completedCallback:Function = null )
		{
			super( completedCallback );
			callName = CALL_NAME;
			requirs.push( "password" );
			response = new EndResponse();
		}
		
		/**
		 * The meeting ID that identifies the meeting you are attempting to end.
		 */
		override public function get meetingID():String
		{
			return super.meetingID;
		}
		
		override public function set meetingID( value:String ):void
		{
			super.meetingID = value;
		}
		
		/**
		 * The moderator password for this meeting. You can not end a meeting using the attendee password.
		 */
		public function get password():String
		{
			return _password;
		}
		
		public function set password( value:String ):void
		{
			_password = value;
			setQuery( "password", value );
		}
	
	}

}