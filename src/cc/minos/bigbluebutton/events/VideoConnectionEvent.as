package cc.minos.bigbluebutton.events {
    import flash.events.Event;

    /**
     * ...
     * @author Minos
     */
    public class VideoConnectionEvent extends Event {
        public static const SUCCESS:String = "videoConnectionSuccess";
        public static const FAILED:String = "videoConnectionFailed";

        public var reason:String;

        public function VideoConnectionEvent(type:String)
        {
            super(type, true, false);
        }

        public override function clone():Event
        {
            var vEvent:VideoConnectionEvent = new VideoConnectionEvent(type);
            vEvent.reason = reason;
            return vEvent;
        }

    }

}