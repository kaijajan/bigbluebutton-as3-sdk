package cc.minos.bigbluebutton.plugins.chat
{
	
	public class ChatMessageVO
	{
		public var chatType:String;
		public var fromUserID:String;
		public var fromUsername:String;
		public var fromColor:String;
		public var fromTime:Number;
		public var fromTimezoneOffset:Number;
		public var fromLang:String;
		public var toUserID:String = "public_chat_userid";
		public var toUsername:String = "public_chat_username";
		public var message:String;
		
		public function ChatMessageVO()
		{
		}
		
		public function toObj():Object
		{
			var m:Object = new Object();
			m.chatType = chatType;
			m.fromUserID = fromUserID;
			m.fromUsername = fromUsername;
			m.fromColor = fromColor;
			m.fromTime = fromTime;
			m.fromTimezoneOffset = fromTimezoneOffset;
			m.fromLang = fromLang;
			m.message = message;
			m.toUserID = toUserID;
			m.toUsername = toUsername;
			
			return m;
		}
	
	}
}