package cc.minos.bigbluebutton.core {

    import flash.events.IOErrorEvent;
    import flash.events.NetStatusEvent;
    import flash.media.Camera;
    import flash.media.H264VideoStreamSettings;
    import flash.net.NetConnection;
    import flash.net.NetStream;

    /**
     * ...
     * @author Minos
     */
    public class VideoConnection extends BaseConnectionCallback implements IVideoConnection {

        protected var bc:BaseConnection;
        protected var outgoingStream:NetStream;

        public function VideoConnection()
        {
            super();
            bc = new BaseConnection(this);
        }

        public function connect(uri:String):void
        {
            bc.connect(uri);
        }

        public function disconnect(userCommand:Boolean):void
        {
            bc.disconnect(userCommand);
        }

        public function startPublish(camera:Camera, publishName:String, h264:H264VideoStreamSettings):void
        {
            if(outgoingStream)
            {
                outgoingStream.addEventListener(NetStatusEvent.NET_STATUS, onStreamNetStatus);
                outgoingStream.addEventListener(IOErrorEvent.IO_ERROR, onStreamIOError);
                outgoingStream.play(null);
                if(h264 != null)
                {
                    outgoingStream.videoStreamSettings = h264;
                }
                outgoingStream.attachCamera(camera);
                outgoingStream.publish(publishName);
            }
        }

        private function onStreamIOError(e:IOErrorEvent):void
        {
            trace("outgoing: " + e.text);
        }

        private function onStreamNetStatus(e:NetStatusEvent):void
        {
            trace("outgoing: " + e.info.code);
        }

        public function stopPublish():void
        {
            if(outgoingStream)
            {
                outgoingStream.publish(null);
                outgoingStream.close();
                outgoingStream = null;
                try
                {
                    outgoingStream = new NetStream(connection);
                }
                catch(er:ArgumentError)
                {
                    trace("net connection failed, please check your network.");
                }
            }
        }

        override internal function onSuccess(reason:String = ""):void
        {
            trace("[VideoConnection] success");
            outgoingStream = new NetStream(connection);
            super.onSuccess(reason);
        }

        override internal function onFailed(reason:String = ""):void
        {
            trace("[VideoConnection] failed " + reason);
            super.onFailed(reason);
            stopPublish();
        }

        public function get connection():NetConnection
        {
            return bc.connection;
        }

    }
}