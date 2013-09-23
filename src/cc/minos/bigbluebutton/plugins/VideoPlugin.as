
package cc.minos.bigbluebutton.plugins
{
	import cc.minos.bigbluebutton.model.BBBUser;
	import cc.minos.bigbluebutton.plugins.users.UsersEvent;
	import cc.minos.bigbluebutton.plugins.video.*;
	import cc.minos.console.Console;
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
		public var options:VideoOptions;
		private var proxy:VideoProxy;
		
		private var _camera:Camera;
		private var streamName:String;
		
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
			proxy = new VideoProxy( this );
			
			if ( bbb.hasPlugin( "users" ) )
				bbb.getPlugin( "users" ).addEventListener( UsersEvent.SWITCHED_PRESENTER, onSwitchedPresenter );
		}
		
		override public function get connection():NetConnection
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
		private function onSwitchedPresenter( e:UsersEvent ):void
		{
			if ( e.userID != me.userID )
			{
				stopPublish();
			}
			Console.log( e.userID + " 獲得演講者權限" );
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
				_camera.setMode( options.videoWidth, options.videoHeight, options.camModeFps );
				_camera.setQuality( options.camQualityBandwidth, options.videoQuality );
				
				var d:Date = new Date();
				var curTime:Number = d.getTime();
				var uid:String = me.userID;
				var res:String = options.videoWidth + "x" + options.videoHeight;
				this.streamName = res.concat( "-" + uid ) + "-" + curTime;
				Console.log( '設置攝像頭成功' );
				return true;
			}
			Console.log( "沒有檢測到攝像頭" );
			return false;
		}
		
		private function onActivityEvent( e:ActivityEvent ):void
		{
			if ( e.activating )
			{
				//trace( "camera activating: " + e.activating );
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