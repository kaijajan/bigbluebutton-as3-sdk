package cc.minos.bigbluebutton.plugins.chat
{
	
	/**
	 * 聊天信息數據
	 */
	public class ChatMessageVO
	{
		/** 信息類型 */
		public var chatType:String;
		/** 發送者用戶ID */
		public var fromUserID:String;
		/** 發送者用戶名稱 */
		public var fromUsername:String;
		/** 顏色 */
		public var fromColor:String;
		/** 時間 */
		public var fromTime:Number;
		/** */
		public var fromTimezoneOffset:Number;
		/** 語言 */
		public var fromLang:String;
		/** 接收者 */
		public var toUserID:String = "public_chat_userid";
		/** 接收者用戶名稱 */
		public var toUsername:String = "public_chat_username";
		/** 信息 */
		public var message:String;
		
		public function ChatMessageVO()
		{
		}
		
		/**
		 * 轉到對象以供發送
		 * @return
		 */
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