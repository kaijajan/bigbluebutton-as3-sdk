package cc.minos.bbb
{
	import flash.net.NetConnection;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class ConferenceParameters
	{
		
		public var meetingName:String;
		
		public var externMeetingID:String;
		
		/**
		 * The name of the conference
		 */
		public var conference:String;
		
		/**
		 * The username of the local user
		 */
		public var username:String;
		
		/**
		 * The role of the local user. Could be MODERATOR or VIEWER
		 */
		public var role:String = "VIEWER";
		
		/**
		 * The room unique id, as specified in the API /create call.
		 */
		public var room:String;
		
		/**
		 * Voice conference bridge for the client
		 */
		public var webvoiceconf:String;
		
		/**
		 * Voice conference bridge that external SIP clients use. Usually the same as webvoiceconf
		 */
		public var voicebridge:String;
		
		/**
		 *  The welcome string, as passed in through the API /create call.
		 */
		public var welcome:String;
		
		public var meetingID:String;
		/**
		 * External unique user id.
		 */
		public var externUserID:String;
		
		/**
		 * Internal unique user id.
		 */
		public var internalUserID:String;
		
		public var logoutUrl:String;
		
		/**
		 * A flash.net.NetConnection object that bbb-client connects to on startup. This connection reference is
		 * passed to your module as an already open connection. Use it to talk to the bigbluebutton server.
		 */
		public var connection:NetConnection;
		
		/**
		 * The unique userid internal to bbb-client.
		 */
		public var userid:String;
		public var record:Boolean = false;
		public var mode:String = "LIVE";
		public var protocol:String = "RTMP";
		public var host:String;
		
		public const application:String = "bigbluebutton";
		
		public function ConferenceParameters()
		{
		}
		
		public function get uri():String
		{
			return protocol + "://" + host + "/" + application;
		}
	}

}