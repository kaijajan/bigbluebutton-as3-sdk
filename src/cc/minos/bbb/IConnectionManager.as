
package cc.minos.bbb
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IConnectionManager
	{
		
		///////////////////////
		// METHODS
		///////////////////////
		
		function connect():void;
		function disconnect():void;
		
		///////////////////////
		// GETTERS/SETTERS
		///////////////////////
		
		function set conference( value:ConferenceParameters ):void
		function get conference():ConferenceParameters;
	
	}
}