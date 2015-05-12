package cc.minos.bigbluebutton.events {
    import flash.events.Event;

    public class PresentationEvent extends Event {
        public static const PRESENTATION_LOADED:String = "Presentation Loaded";
        public static const PRESENTATION_NOT_LOADED:String = "Presentation Not Loaded";

        public static const PRESENTATION_ADDED_EVENT:String = "presentationAdded";

        // Tell the server to remove the presentation.
        public static const REMOVE_PRESENTATION_EVENT:String = "Remove Presentation Event";

        // Presentation has been removed from server.
        public static const PRESENTATION_REMOVED_EVENT:String = "Presentation Removed Event";

        //
        public static const PRESENTATION_READY:String = "PRESENTATION_READY";

        public var presentationName:String;
        public var slides:Array;

        public function PresentationEvent(type:String)
        {
            super(type, false, false);
        }

        override public function clone():Event
        {
            var evt:PresentationEvent = new PresentationEvent(type);
            evt.presentationName = presentationName;
            evt.slides = slides;
            return evt;
        }
    }
}