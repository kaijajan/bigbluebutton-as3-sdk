package cc.minos.bigbluebutton.plugins.video
{
	import cc.minos.bigbluebutton.core.IVideoConnection;
	import cc.minos.bigbluebutton.core.VideoConnection;
	import cc.minos.bigbluebutton.events.ConnectionFailedEvent;
	import cc.minos.bigbluebutton.events.ConnectionSuccessEvent;
	import cc.minos.bigbluebutton.events.MadePresenterEvent;
	import cc.minos.bigbluebutton.events.VideoConnectionEvent;
	import cc.minos.bigbluebutton.plugins.Plugin;
	import cc.minos.bigbluebutton.plugins.users.IUsersPlugin;
	import flash.events.ActivityEvent;
	import flash.events.StatusEvent;
	import flash.media.Camera;
	import flash.media.H264VideoStreamSettings;
	import flash.net.NetConnection;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class VideoPlugin extends Plugin implements IVideoPlugin
	{
		protected var streamName:String;
		protected var _camera:Camera;
		protected var options:VideoOptions;
		protected var videoConnection:IVideoConnection;
		
		public var publishing:Boolean = false;
		
		public function VideoPlugin( options:VideoOptions = null )
		{
			super();
			if ( options == null )
				options = new VideoOptions();
			this.options = options;
			this._application = "video";
			this._name = "[VideoPlugin]";
			this._shortcut = "video";
		}
		
		override public function init():void
		{
			videoConnection = new VideoConnection();
			( videoConnection as VideoConnection ).addEventListener( ConnectionSuccessEvent.SUCCESS, onConnectionSuccess );
			( videoConnection as VideoConnection ).addEventListener( ConnectionFailedEvent.FAILED, onConnectionFailed );
			
			bbb.addEventListener( MadePresenterEvent.SWITCH_TO_VIEWER_MODE, onPresenterChanged );
		}
		
		private function onConnectionFailed( e:ConnectionFailedEvent ):void
		{
			var vEvent:VideoConnectionEvent = new VideoConnectionEvent( VideoConnectionEvent.FAILED );
			vEvent.reason = e.reason;
			dispatchRawEvent( vEvent );
		}
		
		private function onConnectionSuccess( e:ConnectionSuccessEvent ):void
		{
			var vEvent:VideoConnectionEvent = new VideoConnectionEvent( VideoConnectionEvent.SUCCESS );
			dispatchRawEvent( vEvent );
		}
		
		private function onPresenterChanged( e:MadePresenterEvent ):void
		{
			stopPublish();
		}
		
		override public function start():void
		{
			if ( connection != null && !connection.connected )
			{
				videoConnection.connect( uri );
			}
		}
		
		override public function stop():void
		{
			videoConnection.disconnect( true );
		}
		
		override public function get connection():NetConnection
		{
			return videoConnection.connection;
		}
		
		protected function setupCamera():Boolean
		{
			_camera = Camera.getCamera();
			if ( camera )
			{
				camera.setMotionLevel( 5, 1000 );
				if ( camera.muted )
				{
				}
				
				camera.addEventListener( ActivityEvent.ACTIVITY, onActivityEvent );
				camera.addEventListener( StatusEvent.STATUS, onStatusEvent );
				
				camera.setKeyFrameInterval( options.camKeyFrameInterval );
				camera.setMode( options.videoWidth, options.videoHeight, options.camModeFps );
				camera.setQuality( options.camQualityBandwidth, options.videoQuality );
				
				var d:Date = new Date();
				var curTime:Number = d.getTime();
				var uid:String = userID;
				var res:String = options.videoWidth + "x" + options.videoHeight;
				streamName = res.concat( "-" + uid ) + "-" + curTime;
				return true;
			}
			return false;
		}
		
		private function onActivityEvent( e:ActivityEvent ):void
		{
		
		}
		
		private function onStatusEvent( e:StatusEvent ):void
		{
		
		}
		
		public function startPublish():void
		{
			if ( options.presenterShareOnly && !presenter )
			{
				trace( name + " presenter share only." );
				return;
			}
			
			if ( setupCamera() )
			{
				var h264:H264VideoStreamSettings = null;
				if ( options.enableH264 )
				{
					h264 = new H264VideoStreamSettings();
					h264.setProfileLevel( options.h264Profile, options.h264Level );
				}
				videoConnection.startPublish( camera, streamName, h264 );
				publishing = true;
				if ( usersPlugin )
				{
					usersPlugin.addStream( userID, streamName );
				}
			}
			else
			{
				trace( name + " camera not found." );
			}
		}
		
		public function stopPublish():void
		{
			if ( publishing )
			{
				publishing = false;
				videoConnection.stopPublish();
				if ( usersPlugin )
				{
					usersPlugin.removeStream( userID, streamName );
				}
			}
		}
		
		protected function get usersPlugin():IUsersPlugin
		{
			return bbb.getPlugin( "users" ) as IUsersPlugin;
		}
		
		public function get camera():Camera
		{
			return _camera;
		}
	
	}
}