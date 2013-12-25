package cc.minos.bigbluebutton.core
{
	import flash.media.Camera;
	import flash.media.H264VideoStreamSettings;
	import flash.net.NetConnection;
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IVideoConnection
	{
		
		function connect( uri:String ):void;
		function disconnect( userCommand:Boolean ):void;
		function startPublish( camera:Camera, publishName:String, h264:H264VideoStreamSettings ):void;
		function stopPublish():void;
		
		function get connection():NetConnection;
	
	}
}