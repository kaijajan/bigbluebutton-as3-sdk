package cc.minos.bigbluebutton.events {
    import flash.events.Event;

    public class ZoomEvent extends Event {
        public static const ZOOM:String = "ZOOM";
        public static const MAXIMIZE:String = "MAXIMIZE";
        public static const RESTORE:String = "RESTORE";
        public static const RESIZE:String = "RESIZE";

        public var zoomPercentage:Number;

        public var xOffset:Number;
        public var yOffset:Number;

        public var slideToCanvasWidthRatio:Number;
        public var slideToCanvasHeightRatio:Number;

        public function ZoomEvent(type:String)
        {
            super(type, true, false);
        }

    }
}