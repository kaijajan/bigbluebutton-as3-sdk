package cc.minos.bigbluebutton.plugins.users
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IParticipantsCallback
	{
		function assignPresenterCallback( userID:String, name:String, assignedBy:String ):void;
		function kickUserCallback( userID:String ):void;
		function participantStatusChange( userID:String, status:String, value:Object ):void;
		function logout():void;
	}

}