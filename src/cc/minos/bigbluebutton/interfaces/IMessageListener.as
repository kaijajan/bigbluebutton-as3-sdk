package cc.minos.bigbluebutton.interfaces
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IMessageListener
	{
		function onMessage( messageName:String, message:Object ):void;
	}

}