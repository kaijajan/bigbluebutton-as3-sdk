package cc.minos.bigbluebutton
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