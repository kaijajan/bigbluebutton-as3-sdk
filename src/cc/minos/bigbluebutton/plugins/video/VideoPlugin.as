package cc.minos.bigbluebutton.plugins.video {

    import cc.minos.bigbluebutton.core.IVideoConnection;
    import cc.minos.bigbluebutton.core.VideoConnection;
    import cc.minos.bigbluebutton.events.CameraEvent;
    import cc.minos.bigbluebutton.events.ConnectionFailedEvent;
    import cc.minos.bigbluebutton.events.ConnectionSuccessEvent;
    import cc.minos.bigbluebutton.events.MadePresenterEvent;
    import cc.minos.bigbluebutton.events.VideoConnectionEvent;
    import cc.minos.bigbluebutton.plugins.Plugin;
    import cc.minos.bigbluebutton.plugins.users.IUsersPlugin;

    import flash.events.ActivityEvent;
    import flash.events.StatusEvent;
    import flash.events.TimerEvent;
    import flash.media.Camera;
    import flash.media.H264VideoStreamSettings;
    import flash.net.NetConnection;
    import flash.utils.Timer;

    /**
     * ...
     * @author Minos
     */
    public class VideoPlugin extends Plugin implements IVideoPlugin {
        protected var streamName:String;
        protected var _camera:Camera;
        protected var options:VideoOptions;
        protected var videoConnection:IVideoConnection;

        protected var publishing:Boolean = false;

        //
        protected var activationTimer:Timer;
        protected var waitingForActivation:Boolean = false;
        protected var cameraAccessDenied:Boolean = false;
        protected var autoPublishTimer:Timer;

        public function VideoPlugin(options:VideoOptions = null)
        {
            super();
            if(options == null)
                options = new VideoOptions();
            this.options = options;
            this._application = "video";
            this._name = "[VideoPlugin]";
            this._shortcut = "video";
        }

        override public function init():void
        {
            videoConnection = new VideoConnection();
            ( videoConnection as VideoConnection ).addEventListener(ConnectionSuccessEvent.SUCCESS, onConnectionSuccess);
            ( videoConnection as VideoConnection ).addEventListener(ConnectionFailedEvent.FAILED, onConnectionFailed);

            bbb.addEventListener(MadePresenterEvent.SWITCH_TO_VIEWER_MODE, onPresenterChanged);
        }

        private function onConnectionFailed(e:ConnectionFailedEvent):void
        {
            var vEvent:VideoConnectionEvent = new VideoConnectionEvent(VideoConnectionEvent.FAILED);
            vEvent.reason = e.reason;
            dispatchRawEvent(vEvent);
        }

        private function onConnectionSuccess(e:ConnectionSuccessEvent):void
        {
            var vEvent:VideoConnectionEvent = new VideoConnectionEvent(VideoConnectionEvent.SUCCESS);
            dispatchRawEvent(vEvent);

            if(options.autoStart)
            {
                autoPublishTimer = new Timer(3000, 1);
                autoPublishTimer.addEventListener(TimerEvent.TIMER, onAutoPublishTimer);
                autoPublishTimer.start();
            }
        }

        private function onPresenterChanged(e:MadePresenterEvent):void
        {
            stopPublish();
        }

        override public function start():void
        {
            if(connection != null && !connection.connected)
            {
                videoConnection.connect(uri);
            }
        }

        override public function stop():void
        {
            videoConnection.disconnect(true);
        }

        override public function get connection():NetConnection
        {
            return videoConnection.connection;
        }

        protected function updateCamera():void
        {
            stopCamera();

            if(Camera.names.length == 0)
            {
                sendCameraWarning('camera.notfound');
                return;
            }

            _camera = Camera.getCamera();
            if(_camera == null)
            {
                sendCameraWarning('camera.used');
                return;
            }

            _camera.setMotionLevel(5, 1000);
            if(_camera.muted)
            {
                if(cameraAccessDenied)
                {
                    onCameraAccessDisallowed();
                    return;
                }
                else
                {
                    sendCameraWarning('camera.waiting');
                }
            }
            else
            {
                onCameraAccessAllowed();
            }

            _camera.addEventListener(ActivityEvent.ACTIVITY, onActivityEvent);
            _camera.addEventListener(StatusEvent.STATUS, onStatusEvent);

            _camera.setKeyFrameInterval(options.camKeyFrameInterval);
            _camera.setMode(options.videoWidth, options.videoHeight, options.camModeFps);
            _camera.setQuality(options.camQualityBandwidth, options.videoQuality);

            var d:Date = new Date();
            var curTime:Number = d.getTime();
            var uid:String = userID;
            var res:String = options.videoWidth + "x" + options.videoHeight;
            streamName = res.concat("-" + uid) + "-" + curTime;
            return;
        }

        private function onCameraAccessDisallowed():void
        {
            sendCameraWarning('camera.denied');
            cameraAccessDenied = true;
        }

        private function onCameraAccessAllowed():void
        {
            waitingForActivation = true;
            if(activationTimer != null)
            {
                activationTimer.stop();
            }
            activationTimer = new Timer(10000, 1);
            activationTimer.addEventListener(TimerEvent.TIMER, onActivationTimer);
            activationTimer.start();
        }

        private function onActivationTimer(e:TimerEvent):void
        {

            //camera is being used
            updateCamera();
        }

        private function stopCamera():void
        {
            if(_camera)
            {
                _camera.removeEventListener(ActivityEvent.ACTIVITY, onActivityEvent);
                _camera.removeEventListener(StatusEvent.STATUS, onStatusEvent);
            }
            _camera = null;
            var sEvent:CameraEvent = new CameraEvent(CameraEvent.CLOSE);
            dispatchRawEvent(sEvent);
        }

        /**
         * dispatch a event to
         * @param    msg
         * @param    color
         */
        private function sendCameraWarning(text:String, color:uint = 0xff0000):void
        {
            trace(text);
            var warningEvent:CameraEvent = new CameraEvent(CameraEvent.WARNING);
            warningEvent.data = { message: text, color: color };
            dispatchRawEvent(warningEvent);
        }

        private function onAutoPublishTimer(e:TimerEvent):void
        {
            autoPublishTimer.stop();
            startPublish();
        }

        private function onActivityEvent(e:ActivityEvent):void
        {
            trace(e);
            if(waitingForActivation && e.activating)
            {
                activationTimer.stop();
                waitingForActivation = false;

                autoPublishTimer = new Timer(3000, 1);
                autoPublishTimer.addEventListener(TimerEvent.TIMER, onAutoPublishTimer);
                autoPublishTimer.start();
            }
        }

        private function onStatusEvent(e:StatusEvent):void
        {
            trace(e);
            if(e.code == "Camera.Unmuted")
            {
                onCameraAccessAllowed();
                sendCameraWarning('camera.opening');
            }
            else if(e.code == "Camera.Muted")
            {
                onCameraAccessDisallowed();
            }
        }

        public function startPublish():void
        {
            trace("try start publish video");
            if(publishing)
            {
                trace('publishing video');
                return;
            }

            if(options.presenterShareOnly && !presenter)
            {
                trace(name + " presenter share only.");
                return;
            }

            updateCamera();
            if(_camera == null)
                return

            if(autoPublishTimer)
            {
                autoPublishTimer.stop();
                autoPublishTimer.removeEventListener(TimerEvent.TIMER, onAutoPublishTimer);
                autoPublishTimer = null;
            }

            var h264:H264VideoStreamSettings = null;
            if(options.enableH264)
            {
                h264 = new H264VideoStreamSettings();
                h264.setProfileLevel(options.h264Profile, options.h264Level);
            }
            videoConnection.startPublish(_camera, streamName, h264);
            publishing = true;
            if(usersPlugin)
            {
                usersPlugin.addStream(userID, streamName);
            }
        }

        public function stopPublish():void
        {
            if(publishing)
            {
                stopCamera();
                publishing = false;
                videoConnection.stopPublish();
                if(usersPlugin)
                {
                    usersPlugin.removeStream(userID, streamName);
                }
            }
        }

        protected function get usersPlugin():IUsersPlugin
        {
            return bbb.getPlugin("users") as IUsersPlugin;
        }

        public function get camera():Camera
        {
            if(_camera == null)
                updateCamera();
            return _camera;
        }

        public function get isPublishing():Boolean
        {
            return publishing;
        }

    }
}