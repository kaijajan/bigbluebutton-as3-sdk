package cc.minos.bigbluebutton.events {
    import flash.events.Event;

    /**
     * ...
     * @author Minos
     */
    public class CameraEvent extends Event {
        public static const WARNING:String = "cameraWarning";
        public static const CLOSE:String = 'cameraClose';

        public var data:Object = {};

        public function CameraEvent(type:String)
        {
            super(type, true, false);
        }

        public override function clone():Event
        {
            var c:CameraEvent = new CameraEvent(type);
            c.data = data;
            return c;
        }

    }

}