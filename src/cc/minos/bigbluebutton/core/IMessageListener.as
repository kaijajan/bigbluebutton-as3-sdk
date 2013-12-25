package cc.minos.bigbluebutton.core
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