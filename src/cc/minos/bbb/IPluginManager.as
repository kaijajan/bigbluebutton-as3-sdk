

package cc.minos.bbb
{
	import cc.minos.bbb.plugins.Plugin;

	/**
	 * ...
	 * @author Minos
	 */
	public interface IPluginManager
	{

		///////////////////////
		// METHODS
		///////////////////////
		
		 function addPlugin(pi:Plugin):void;
		 function delPlugin(pi:Plugin):void;
		 function getPlugin(shortcut:String):Plugin;
	}
}