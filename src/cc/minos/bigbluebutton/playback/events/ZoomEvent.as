package cc.minos.bigbluebutton.playback.events {
    import flash.events.Event;

    /**
     * ...
     * @author Minos
     */
    public class ZoomEvent extends Event {
        public static const ZOOM:String = "playback.zoom";

        public var x:Number;
        public var y:Number;
        public var width:Number;
        public var height:Number;

        public function ZoomEvent()
        {
            super(ZOOM, true, false);
        }

        public override function clone():Event
        {
            var cE:ZoomEvent = new ZoomEvent();
            cE.x = x;
            cE.y = y;
            cE.width = width;
            cE.height = height;
            return cE;
        }

    }

}