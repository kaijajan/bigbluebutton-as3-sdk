package cc.minos.bigbluebutton.interfaces
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IMessageManager
	{
		function addMessageListener( listener:IMessageListener ):void;
		function removeMessageListener( listener:IMessageListener ):void;
		function onMessageFromServer( messageName:String, result:Object ):void;
		function send( args:Array ):void;
	}

}