package cc.minos.bigbluebutton.interfaces
{
	import cc.minos.bigbluebutton.plugins.Plugin;
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IPluginManager
	{
		function addPlugin( pi:Plugin ):void;
		function removePlugin( shortcut:String ):void;
		function getPlugin( shortcut:String ):Plugin;
		function hasPlugin( shortcut:String ):Boolean;
	}

}