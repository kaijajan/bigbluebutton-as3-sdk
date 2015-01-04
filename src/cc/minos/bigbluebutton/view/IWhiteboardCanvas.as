package cc.minos.bigbluebutton.view {
    import cc.minos.bigbluebutton.models.Annotation;
    import cc.minos.bigbluebutton.view.shapes.GraphicObject;

    import flash.display.DisplayObject;

    /**
     * ...
     * @author Minos
     */
    public interface IWhiteboardCanvas {
        function addGraphic(g:GraphicObject):void;

        function removeGraphic(g:GraphicObject):void

        function getGraphicById(id:String):Object;

        function undo():void;

        function clear():void;
    }

}