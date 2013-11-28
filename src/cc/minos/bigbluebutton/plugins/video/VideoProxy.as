package cc.minos.bigbluebutton.plugins.video
{
	import cc.minos.console.Console;
	import cc.minos.utils.VersionUtil;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Camera;
	import flash.media.H264Level;
	import flash.media.H264Profile;
	import flash.media.H264VideoStreamSettings;
	import flash.media.Video;
	import flash.net.FileReference;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Capabilities;
	
	/**
	 * 視頻流代理
	 * 視頻發布控制
	 */
	public class VideoProxy
	{
		/** 視頻連接 */
		private var nc:NetConnection;
		/** 視頻流 */
		private var ns:NetStream;
		/** */
		private var options:VideoOptions;
		/** */
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
		
		/**
		 * 連接視頻服務器
		 * @param	uri
		 */
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
		
		/**
		 *
		 * @param	e
		 */
		private function onNetStatus( e:NetStatusEvent ):void
		{
			Console.log( e.info.code );
			switch ( e.info.code )
			{
				case "NetConnection.Connect.Success": 
					ns = new NetStream( nc );
					var connectedEvent:VideoEvent = new VideoEvent( VideoEvent.VIDEO_APPLICATION_CONNECTED );
					connectedEvent.connection = nc;
					plugin.dispatchEvent( connectedEvent );
					break;
				case "NetConnection.Connect.Closed": 
					plugin.dispatchEvent( new VideoEvent( VideoEvent.VIDEO_APPLICATION_CLOSED ) );
					break;
				default: 
					break;
			}
		}
		
		public function get connection():NetConnection
		{
			return this.nc;
		}
		
		/**
		 * 開始發布視頻流
		 * @param	camera		:	攝像頭
		 * @param	stream		:	視頻流名稱
		 */
		public function startPublishing( camera:Camera, stream:String ):void
		{
			ns.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
			ns.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			ns.addEventListener( AsyncErrorEvent.ASYNC_ERROR, onAsyncError );
			ns.client = this;
			ns.play(null);
			//視頻發布格式 h264播放器必須在11以上
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
			
			/*var file:FileReference = new FileReference()
			file.addEventListener(Event.COMPLETE, onFileComplete );
			file.addEventListener(Event.SELECT, onFileSelect );
			file.browse();
			
			function onFileSelect( e:Event ):void
			{
				file.load();
			}
			
			function onFileComplete( e:Event ):void
			{
				//trace( file.data );
				ns.appendBytes( file.data );
				//ns.
			}*/
		}
		
		/**
		 * 停止發布視頻流
		 */
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
