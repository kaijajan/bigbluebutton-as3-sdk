package cc.minos.bigbluebutton.plugins.users
{
	
	/**
	 * 用戶語音接口
	 * @author Minos
	 */
	public interface IListeners
	{
		function ejectUser( userID:Number ):void
		function muteAllUsers( mute:Boolean ):void
		function muteUnmuteUser( userID:Number, mute:Boolean ):void
		function lockMuteUser( userID:Number, lock:Boolean ):void
	}

}