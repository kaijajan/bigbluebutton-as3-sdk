package cc.minos.bigbluebutton.plugins.users
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IListenersCallback
	{
		function userLeft( userID:Number ):void;
		function userTalk( userID:Number, talk:Boolean ):void;
		function userLockedMute( userID:Number, locked:Boolean ):void;
		function userMute( userID:Number, mute:Boolean ):void;
		function userJoin( userID:Number, cidName:String, cidNum:String, muted:Boolean, talking:Boolean, locked:Boolean ):void;
	}

}