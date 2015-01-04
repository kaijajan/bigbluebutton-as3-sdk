package cc.minos.bigbluebutton.playback.steps {
    import cc.minos.bigbluebutton.playback.Constants;
    import cc.minos.bigbluebutton.playback.style.Style;
    import cc.minos.bigbluebutton.playback.utils.StyleUtil;

    import flash.display.Shape;

    /**
     * ...
     * @author Minos
     */
    public class ShapeElement extends Shape implements IStep, IElement {
        private var _id:String = "undefined";
        private var _inTime:Number = 0;
        private var _outTime:Number = Number.MAX_VALUE;
        private var _xml:XML = null;

        private var style:Style;
        private var _type:String = "shape";

        public function ShapeElement(xml:* = null)
        {
            if(xml != null)
                this.xml = new XML(xml);
        }

        /* INTERFACE cc.minos.bigbluebutton.playback.steps.IStep */

        public function get id():String
        {
            return _id;
        }

        public function set id(value:String):void
        {
            _id = value;
        }

        public function get inTime():Number
        {
            return _inTime;
        }

        public function set inTime(value:Number):void
        {
            _inTime = value;
        }

        public function get outTime():Number
        {
            return _outTime;
        }

        public function set outTime(value:Number):void
        {
            _outTime = value;
        }

        public function inRange(time:Number):Boolean
        {
            if(time >= inTime)
                return true;
            return false;
        }

        public function step(time:Number):void
        {
            if(inRange(time))
                this.visible = true;
            else
                this.visible = false;
        }

        public function get type():String
        {
            return _type;
        }

        public function set type(value:String):void
        {
            _type = value;
        }

        public function set xml(value:XML):void
        {
            _xml = value;
            init();
        }

        public function get xml():XML
        {
            return _xml;
        }

        protected function init():void
        {
            style = new Style(this.xml);

            var ns:Namespace = Constants.svg;

            this.graphics.clear();
            this.graphics.lineStyle(style.stroke_width, style.stroke, style.stroke_opacity, false, "normal", style.stroke_linecap, style.stroke_linejoin);

            for each (var line:XML in this.xml.ns::line)
            {
                this.graphics.moveTo(line.@x1, line.@y1);
                this.graphics.lineTo(line.@x2, line.@y2);
            }

            this.id = this.xml.@id;
            this.name = this.xml.@shape;
            this.inTime = Number(this.xml.@id.toString().replace("draw", ""));
        }

    }

}