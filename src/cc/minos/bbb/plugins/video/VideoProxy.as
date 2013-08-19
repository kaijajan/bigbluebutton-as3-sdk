package cc.minos.bbb.plugins.video
{
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
	
	public class VideoProxy extends EventDispatcher
	{
		private var nc:NetConnection;
		private var ns:NetStream;
		private var _url:String;
		private var options:VideoOptions;
		
		public function VideoProxy( options:VideoOptions )
		{
			this.options = options;
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
		
		private function onAsyncError( event:AsyncErrorEvent ):void
		{
		}
		
		private function onIOError( event:NetStatusEvent ):void
		{
		}
		
		private function onSecurityError( event:NetStatusEvent ):void
		{
		}
		
		private function onNetStatus( event:NetStatusEvent ):void
		{
			switch ( event.info.code )
			{
				case "NetConnection.Connect.Success": 
					ns = new NetStream( nc );
					dispatchEvent( new ConnectedEvent( ConnectedEvent.VIDEO_CONNECTED ) );
					break;
				default: 
					trace( "[" + event.info.code + "] for [VideoProxy]" );
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
				trace( "Using H264 codec for video." );
				var h264:H264VideoStreamSettings = new H264VideoStreamSettings();
				var h264profile:String = H264Profile.MAIN;
				if ( options.h264Profile != "main" )
				{
					h264profile = H264Profile.BASELINE;
				}
				var h264Level:String = H264Level.LEVEL_4_1;
				if ( options.h264Level == "1" )
				{
					h264Level = H264Level.LEVEL_1;
				}
				else if ( options.h264Level == "1.1" )
				{
					h264Level = H264Level.LEVEL_1_1;
				}
				else if ( options.h264Level == "1.2" )
				{
					h264Level = H264Level.LEVEL_1_2;
				}
				else if ( options.h264Level == "1.3" )
				{
					h264Level = H264Level.LEVEL_1_3;
				}
				else if ( options.h264Level == "1b" )
				{
					h264Level = H264Level.LEVEL_1B;
				}
				else if ( options.h264Level == "2" )
				{
					h264Level = H264Level.LEVEL_2;
				}
				else if ( options.h264Level == "2.1" )
				{
					h264Level = H264Level.LEVEL_2_1;
				}
				else if ( options.h264Level == "2.2" )
				{
					h264Level = H264Level.LEVEL_2_2;
				}
				else if ( options.h264Level == "3" )
				{
					h264Level = H264Level.LEVEL_3;
				}
				else if ( options.h264Level == "3.1" )
				{
					h264Level = H264Level.LEVEL_3_1;
				}
				else if ( options.h264Level == "3.2" )
				{
					h264Level = H264Level.LEVEL_3_2;
				}
				else if ( options.h264Level == "4" )
				{
					h264Level = H264Level.LEVEL_4;
				}
				else if ( options.h264Level == "4.1" )
				{
					h264Level = H264Level.LEVEL_4_1;
				}
				else if ( options.h264Level == "4.2" )
				{
					h264Level = H264Level.LEVEL_4_2;
				}
				else if ( options.h264Level == "5" )
				{
					h264Level = H264Level.LEVEL_5;
				}
				else if ( options.h264Level == "5.1" )
				{
					h264Level = H264Level.LEVEL_5_1;
				}
				
				trace( "Codec used: " + h264Level );
				
				h264.setProfileLevel( h264profile, h264Level );
				ns.videoStreamSettings = h264;
			}
			
			ns.publish( stream );
		}
		
		public function stopBroadcasting():void
		{
			trace( "Closing netstream for webcam publishing" );
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
			trace( "VideoProxy:: disconnecting from Video application" );
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
			// your application should do something here 
			// when the bandwidth check is complete 
			trace( "bandwidth = " + p_bw + " Kbps." );
		}
	
	}
}
