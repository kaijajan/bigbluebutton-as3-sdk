package cc.minos.bigbluebutton.plugins.users
{
	
	/**
	 * 用戶狀態接口
	 * @author Minos
	 */
	public interface IParticipants
	{
		function addStream( userID:String, streamName:String ):void;
		function removeStream( userID:String, streamName:String ):void;
		function assignPresenter( userid:String, name:String, assignedBy:Number ):void;
		function raiseHand( userID:String, raise:Boolean ):void;
		function kickUser( userID:String ):void;
	}

}