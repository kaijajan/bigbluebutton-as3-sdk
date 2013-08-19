package cc.minos.bigbluebutton.plugins
{
	import cc.minos.bigbluebutton.plugins.chat.*;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class ChatPlugin extends Plugin
	{
		
		private var publicChatSOS:PublicChatSOService;
		
		public function ChatPlugin()
		{
			super();
			this.name = "[ChatPlugin]";
			this.shortcut = "chat";
		}
		
		override public function init():void
		{
			publicChatSOS = new PublicChatSOService( this );
		}
		
		override public function start():void
		{
			publicChatSOS.connect();
		}
		
		override public function stop():void
		{
			publicChatSOS.disconnect();
		}
		
		override public function get uri():String
		{
			var _uri:String = super.uri + "/" + bbb.conferenceParameters.room;
			return _uri;
		}
		
		public function sendMessage( message:String, username:String, color:String, time:String, language:String, userid:String ):void
		{
			publicChatSOS.sendMessage( message, username, color, time, language, userid );
		}
	
	}
}