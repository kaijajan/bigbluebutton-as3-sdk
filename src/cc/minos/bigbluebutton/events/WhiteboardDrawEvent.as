package cc.minos.bigbluebutton.events {
    import cc.minos.bigbluebutton.models.Annotation;

    import flash.events.Event;

    /**
     * ...
     * @author Minos
     */
    public class WhiteboardDrawEvent extends Event {

        public static const CHANGE_PRESENTATION:String = "whiteboard.changePresentation";
        public static const CHANGE_PAGE:String = "whiteboard.changePage";
        public static const CLEAR:String = "whiteboard.clear";
        public static const UNDO:String = "whiteboard.undo";
        public static const NEW_ANNOTATION:String = "whiteboard.newAnnotation";

        public var presentationID:String;
        public var numberOfPages:int

        public var pageNum:int;

        public var numAnnotations:int;

        public var annotation:Annotation;

        public function WhiteboardDrawEvent(type:String)
        {
            super(type, true, false);
        }

        public override function clone():Event
        {
            var e:WhiteboardDrawEvent = new WhiteboardDrawEvent(type);
            e.presentationID = presentationID;
            e.numberOfPages = numberOfPages;
            e.pageNum = pageNum;
            e.annotation = annotation;
            e.numAnnotations = numAnnotations;
            return e;
        }

    }

}