package cc.minos.bigbluebutton.plugins.video
{
	import cc.minos.bigbluebutton.core.IVideoConnection;
	import cc.minos.bigbluebutton.core.VideoConnection;
	import cc.minos.bigbluebutton.events.MadePresenterEvent;
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
	public class VideoPlugin extends Plugin
	{
		protected var streamName:String;
		protected var camera:Camera;
		protected var options:VideoOptions;
		protected var videoConnection:IVideoConnection;
		
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
			bbb.addEventListener( MadePresenterEvent.SWITCH_TO_VIEWER_MODE, onPresenterChanged );
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
			camera = Camera.getCamera();
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
		
		private function onActivityEvent(e:ActivityEvent):void 
		{
			
		}
		
		private function onStatusEvent(e:StatusEvent):void 
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
			videoConnection.stopPublish();
			if ( usersPlugin )
			{
				usersPlugin.removeStream( userID, streamName );
			}
		}
		
		protected function get usersPlugin():IUsersPlugin
		{
			return bbb.getPlugin( "users" ) as IUsersPlugin;
		}
	
	}
}