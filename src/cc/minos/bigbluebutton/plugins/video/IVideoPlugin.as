package cc.minos.bigbluebutton.plugins.video
{
	import flash.media.Camera;
	import flash.net.NetConnection;
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IVideoPlugin
	{
		function startPublish():void;
		function stopPublish():void;
		function get camera():Camera;
		function get connection():NetConnection;
	}

}