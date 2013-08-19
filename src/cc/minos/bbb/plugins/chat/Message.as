
package cc.minos.bbb.plugins.chat
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public class Message
	{
		public static const PUBLIC_CHAT:String = "PUBLIC_CHAT";
		public static const PRIVATE_CHAT:String = "PRIVATE_CHAT";
		
		public var fromUserID:String;
		public var chatType:String;
		public var fromUsername:String;
		public var fromColor:String;
		public var fromTime:Number;
		public var fromTimezoneOffset:Number;
		public var fromLang:String;
		//public var toUserID:String;
		//public var toUsername:String;
		public var message:String;
		
		public var toUserID:String = "public_chat_userid";
		public var toUsername:String = "public_chat_username";
	
		public function Message() {
		}
		
		public function toObj():Object
		{
			return null;
		}
	
	}
}