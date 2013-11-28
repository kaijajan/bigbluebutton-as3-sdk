package cc.minos.bigbluebutton.plugins.users
{
	import cc.minos.bigbluebutton.model.BBBUser;
	import flash.events.Event;
	
	/**
	 * 用戶管理接口
	 * @author Minos
	 */
	public interface IUsersManager
	{
		function addUser( newuser:BBBUser ):void;
		function hasUser( userID:String ):Boolean;
		function hasOnlyOneModerator():Boolean;
		function getTheOnlyModerator():BBBUser;
		function getPresenter():BBBUser;
		function getUser( userID:String ):BBBUser;
		function isUserPresenter( userID:String ):Boolean;
		function removeUser( userID:String ):void;
		function getVoiceUser( voiceUserID:Number ):BBBUser;
		function getMe():BBBUser;
		function getUserIDs():Array;
		function refresh():void;
		
		function dispatchEvent( e:Event ):Boolean;
		function dispatchRawEvent( e:Event ):Boolean;
	}

}