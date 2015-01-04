package cc.minos.bigbluebutton.view {
    import cc.minos.bigbluebutton.models.Annotation;
    import cc.minos.bigbluebutton.view.shapes.GraphicObject;

    /**
     * ...
     * @author Minos
     */
    public interface ISlidesView {
        function getMouseXY():Array;

        function sendGraphicToServer(an:Annotation):void;

        function generateID():String;
    }

}