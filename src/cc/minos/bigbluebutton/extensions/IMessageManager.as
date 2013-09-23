package cc.minos.bigbluebutton.extensions
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
		function sendMessage( service:String, onSuccess:Function = null, onFailed:Function = null, message:Object = null ):void;
	}

}