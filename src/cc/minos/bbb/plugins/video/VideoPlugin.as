
package cc.minos.bbb.plugins.video
{
	import cc.minos.bbb.BBBUser;
	import cc.minos.bbb.plugins.Plugin;
	import cc.minos.bbb.plugins.users.PariticipantEvent;
	import flash.events.ActivityEvent;
	import flash.events.StatusEvent;
	import flash.media.Camera;
	import flash.net.NetConnection;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class VideoPlugin extends Plugin
	{
		private var options:VideoOptions;
		private var proxy:VideoProxy;
		
		private var _camera:Camera;
		private var streamName:String;
		private var camWidth:Number = 320;
		private var camHeight:Number = 240;
		
		public function VideoPlugin( options:VideoOptions = null )
		{
			super();
			this.options = options;
			if ( this.options == null )
				this.options = new VideoOptions();
			this.name = '[VideoPlugin]';
			this.shortcut = 'video';
			this.application = 'video';
		}
		
		override public function init():void
		{
			proxy = new VideoProxy( options );
			proxy.addEventListener( ConnectedEvent.VIDEO_CONNECTED, onVideoAppConnected );
			
			//role
			bbb.plugins[ 'users' ].addEventListener( PariticipantEvent.SWITCHED_PRESENTER, onSwitchedPresenter );
		}
		
		public function get connection():NetConnection
		{
			return proxy.connection;
		}
		
		public function get camera():Camera
		{
			return _camera;
		}
		/**
		 *
		 * @param	e
		 */
		private function onSwitchedPresenter( e:PariticipantEvent ):void
		{
			if ( e.userID != me.userID )
			{
				stopPublish();
					//close vidieo window
			}
			trace( name + " switched presenter" );
		}
		
		private function onVideoAppConnected( e:ConnectedEvent ):void
		{
			trace( name + ' video app connected' );
			dispatchEvent(e);
			//check users hasStream ?   users getPresenter
			var p:BBBUser = bbb.plugins[ 'users' ].getPresenter();
			if ( p != null && p.hasStream )
			{
				//open video window
				trace( "a presenter publishing video" );
			}
		}
		
		override public function start():void
		{
			proxy.connect( uri );
		}
		
		private function get me():BBBUser
		{
			return bbb.plugins[ 'users' ].getMe();
		}
		
		/**
		 * presenter share only
		 */
		public function startPublish():void
		{
			if ( !me.presenter )
				return;
			
			//close video window
			if ( stupCamera() )
			{
				proxy.startPublishing( _camera, streamName );
				bbb.plugins[ 'users' ].addStream( me.userID, streamName );
			}
		}
		
		public function stopPublish():void
		{
			proxy.stopBroadcasting();
			bbb.plugins[ 'users' ].removeStream( me.userID, streamName );
		}
		
		private function stupCamera():Boolean
		{
			_camera = Camera.getCamera();
			if ( _camera )
			{
				_camera.setMotionLevel( 5, 1000 );
				if ( _camera.muted )
				{
				}
				
				_camera.addEventListener( ActivityEvent.ACTIVITY, onActivityEvent );
				_camera.addEventListener( StatusEvent.STATUS, onStatusEvent );
				
				_camera.setKeyFrameInterval( options.camKeyFrameInterval );
				_camera.setMode( camWidth, camHeight, options.camModeFps );
				_camera.setQuality( options.camQualityBandwidth, options.camQualityPicture );
				
				var d:Date = new Date();
				var curTime:Number = d.getTime();
				var uid:String = me.userID;
				var res:String = camWidth + "x" + camHeight;
				this.streamName = res.concat( "-" + uid ) + "-" + curTime;
				trace( 'setup camera success, it can publish video stream' );
				return true;
			}
			trace( "you must have a camera." );
			return false;
		}
		
		private function onActivityEvent( e:ActivityEvent ):void
		{
			if ( e.activating )
			{
				trace( "camera activating: " + e.activating );
			}
		}
		
		private function onStatusEvent( e:StatusEvent ):void
		{
			if ( e.code == "Camera.Unmuted" )
			{
			}
			else if ( e.code == "Camera.Muted" )
			{
			}
		}
	
	}
}