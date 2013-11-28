package cc.minos.bigbluebutton.model
{
	import cc.minos.bigbluebutton.Role;
	import cc.minos.utils.RandomUtil;
	import flash.net.NetConnection;
	
	public class ConferenceParameters
	{
		/** 房間 */
		public var conference:String;
		public var room:String;
		
		/** 會議id */
		public var meetingID:String;
		//public var meetingName:String;
		public var externMeetingID:String;
		
		/** 用戶名 */
		public var username:String;
		
		/** 語音通道 */
		public var webvoiceconf:String;
		public var voicebridge:String;
		
		/** 歡迎語 */
		public var welcome:String;
		
		/** 外部用戶id */
		public var externUserID:String;
		/** 內部用戶id */
		public var internalUserID:String;
		
		/** 推出跳轉地址 */
		public var logoutUrl:String;
		
		/** 網絡連接 */
		public var connection:NetConnection;
		
		/** 用戶id */
		public var userID:String;
		
		/** 服務器地址 */
		public var host:String;
		
		/** 權限 */
		public var role:String = Role.VIEWER;
		
		/** 模式 實時|回放*/
		public var mode:String = "LIVE";
		
		/** 協議 */
		public var protocol:String = "RTMP";
		
		/** 是否記錄 */
		public var record:Boolean = false;
		
		public function ConferenceParameters()
		{
		}
		
		public function load( obj:Object ):void
		{
			host = obj.host;
			username = obj.username;
			voicebridge = webvoiceconf = obj.voicebridge;
			meetingID = conference = room = RandomUtil.randomString( 24 );
			//externMeetingID = obj.metingName;
			externUserID = internalUserID = RandomUtil.randomString( 12 );
			role = obj.role;
			
		}
	
	}
}