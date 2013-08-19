package cc.minos.bigbluebutton.model
{
	import cc.minos.bigbluebutton.Role;
	import flash.net.NetConnection;
	
	public class ConferenceParameters
	{
		public var conference:String;
		public var username:String;
		public var room:String;
		public var webvoiceconf:String;
		public var voicebridge:String;
		public var welcome:String;
		public var meetingID:String;
		public var externUserID:String;
		public var internalUserID:String;
		public var logoutUrl:String;
		public var connection:NetConnection;
		public var userID:String;
		public var host:String;
		public var role:String = Role.VIEWER;
		public var mode:String = "LIVE";
		public var protocol:String = "RTMP";
		public var record:Boolean = false;
		
		public function ConferenceParameters()
		{
		}
	}
}