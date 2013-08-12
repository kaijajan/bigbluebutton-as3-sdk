

package cc.minos.bbb.plugins.chat
{

	/**
	 * ...
	 * @author Minos
	 */
	public class Message
	{
		///////////////////////
		// PROPERTIES
		///////////////////////
		
		public var fromUserID:String;
		public var chatType:String;
		public var fromUsername:String;
		public var fromColor:String;
		public var fromTime:Number;
		public var fromTimezoneOffset:Number;
		public var fromLang:String;
		public var toUserID:String;
		public var toUsername:String;
		public var message:String;

		///////////////////////
		// METHODS
		///////////////////////
		
		public function toObj():Object
		{
			//TODO
			return null;
		}

	}
}