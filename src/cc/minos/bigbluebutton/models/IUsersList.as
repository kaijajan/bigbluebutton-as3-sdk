
package cc.minos.bigbluebutton.models
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IUsersList
	{
		function addUser( user:BBBUser ):void;
		function hasUser( userID:String ):Boolean;
		function hasOnlyOneModerator():Boolean;
		function getTheOnlyModerator():BBBUser;
		function getTheOnlyPresenter():BBBUser;
		function getUser( userID:String ):BBBUser;
		function removeUser( userID:String ):void;
		function getUserByVoiceID( voiceID:Number ):BBBUser;
		function getUserByName( userName:String ):Array;
		function set me( user:BBBUser ):void;
		function get me():BBBUser;
	}
}