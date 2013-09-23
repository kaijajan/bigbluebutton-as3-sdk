package cc.minos.bigbluebutton.plugins.video
{
	import cc.minos.bigbluebutton.plugins.VideoPlugin;
	import cc.minos.console.Console;
	import cc.minos.utils.VersionUtil;
	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Camera;
	import flash.media.H264Level;
	import flash.media.H264Profile;
	import flash.media.H264VideoStreamSettings;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Capabilities;
	
	public class VideoProxy
	{
		private var nc:NetConnection;
		private var ns:NetStream;
		private var _url:String;
		private var options:VideoOptions;
		private var plugin:VideoPlugin;
		
		public function VideoProxy( plugin:VideoPlugin )
		{
			this.plugin = plugin;
			this.options = plugin.options;
			nc = new NetConnection();
			nc.client = this;
			nc.addEventListener( AsyncErrorEvent.ASYNC_ERROR, onAsyncError );
			nc.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			nc.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
			nc.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
		}
		
		public function connect( uri:String ):void
		{
			nc.connect( uri );
		}
		
		private function onAsyncError( e:AsyncErrorEvent ):void
		{
		}
		
		private function onIOError( e:NetStatusEvent ):void
		{
		}
		
		private function onSecurityError( e:NetStatusEvent ):void
		{
		}
		
		private function onNetStatus( e:NetStatusEvent ):void
		{
			Console.log( e.info.code );
			switch ( e.info.code )
			{
				case "NetConnection.Connect.Success": 
					ns = new NetStream( nc );
					plugin.dispatchEvent( new VideoEvent( VideoEvent.VIDEO_APPLICATION_CONNECTED ) );
					break;
				default: 
					break;
			}
		}
		
		public function get connection():NetConnection
		{
			return this.nc;
		}
		
		public function startPublishing( camera:Camera, stream:String ):void
		{
			ns.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
			ns.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			ns.addEventListener( AsyncErrorEvent.ASYNC_ERROR, onAsyncError );
			ns.client = this;
			ns.attachCamera( camera );
			if (( VersionUtil.getFlashPlayerVersion() >= 11 ) && options.enableH264 )
			{
				Console.log( "使用視頻編碼: H264" );
				var h264:H264VideoStreamSettings = new H264VideoStreamSettings();
				h264.setProfileLevel( options.h264Profile, options.h264Level );
				//h264.setQuality( options.camQualityBandwidth , options.videoQuality );
				//h264.setMode( options.videoWidth , options.videoHeight, options.camModeFps );
				//h264.setKeyFrameInterval( options.camKeyFrameInterval );
				ns.videoStreamSettings = h264;
			}
			
			ns.publish( stream );
		}
		
		public function stopBroadcasting():void
		{
			Console.log( "停止視頻發布" );
			
			if ( ns != null )
			{
				ns.attachCamera( null );
				ns.close();
				ns = null;
				ns = new NetStream( nc );
			}
		}
		
		public function disconnect():void
		{
			Console.log( "斷開視頻組件" );
			stopBroadcasting();
			if ( nc != null )
				nc.close();
		}
		
		public function onBWCheck( ... rest ):Number
		{
			return 0;
		}
		
		public function onBWDone( ... rest ):void
		{
			var p_bw:Number;
			if ( rest.length > 0 )
				p_bw = rest[ 0 ];
		}
	
	}
}
