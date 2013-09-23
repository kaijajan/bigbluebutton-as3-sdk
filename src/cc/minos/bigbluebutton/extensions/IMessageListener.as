package cc.minos.bigbluebutton.extensions
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