package cc.minos.bigbluebutton.apis.resources
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public class MeetingInfoResource extends Resource
	{
		public static const CALL_NAME:String = "getMeetingInfo";
		
		protected var _password:String;
		
		public function MeetingInfoResource( completedCallback:Function = null )
		{
			super( completedCallback );
			callName = CALL_NAME;
			requirs.push( "password" );
		}
		
		/**
		 * The moderator password for this meeting. You can not get the meeting information using the attendee password.
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