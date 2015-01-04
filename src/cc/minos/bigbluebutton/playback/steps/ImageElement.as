package cc.minos.bigbluebutton.playback.steps {
    import cc.minos.bigbluebutton.events.GraphicObjectFocusEvent;
    import cc.minos.bigbluebutton.playback.Constants;
    import cc.minos.bigbluebutton.playback.utils.StyleUtil;

    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.net.URLRequest;

    /**
     * ...
     * @author Minos
     */
    public class ImageElement extends Sprite implements IElement, IStep {
        protected var _id:String;
        protected var _inTime:Number;
        protected var _outTime:Number;
        protected var _type:String = "image";

        protected var _imageWidth:Number;
        protected var _imageHeight:Number;
        protected var _width:Number;
        protected var _height:Number;

        protected var _x:Number;
        protected var _y:Number;

        public var loader:Loader;
        protected var canvas:Sprite;
        protected var _xml:XML;

        protected var _href:String;

        protected var shapes:Vector.<ShapeElement>

        protected var host:String = "";

        public function ImageElement(host:String = "", xml:XML = null)
        {
            this.host = host;
            shapes = new Vector.<ShapeElement>();
            if(xml != null)
                this.xml = xml;
        }

        protected function init():void
        {
            var ns:Namespace = Constants.svg;
            var xlink:Namespace = Constants.xlink;

            _x = StyleUtil.toNumber(this.xml.@x);
            _y = StyleUtil.toNumber(this.xml.@y);
            _width = StyleUtil.toNumber(this.xml.@width);
            _height = StyleUtil.toNumber(this.xml.@height);

            _href = this.xml.@xlink::href;

            _inTime = StyleUtil.toNumber(this.xml.@[ "in" ]);
            _outTime = StyleUtil.toNumber(this.xml.@[ "out" ]);

            _id = this.xml.@id;

            if(_href != null)
            {
                loader = new Loader();
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
                loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
                loader.load(new URLRequest(host + _href));
                addChild(loader);
            }

            var list:XMLList = this.xml.parent().ns::g.( @image == this.xml.@id );

            if(list.length() > 0)
            {
                canvas = new Sprite();
                addChild(canvas);

                var shapeXML:XML = list[ 0 ];

                var shape:ShapeElement;
                for each (var g:XML in shapeXML.ns::g)
                {
                    shape = new ShapeElement(g);
                    shape.visible = false;
                    canvas.addChild(shape);
                    shapes.push(shape);
                }
            }
        }

        private function onIOError(e:IOErrorEvent):void
        {
            trace("io error: " + _href);
        }

        private function onComplete(e:Event):void
        {
            _imageWidth = loader.content.width;
            _imageHeight = loader.content.height;

            loader.content.x = _x;
            loader.content.y = _y;
            if(_imageWidth != _width || _imageHeight != _height)
            {
                loader.content.height = _height;
                loader.content.width = _width;
            }
            loader.x = loader.content.x;
            loader.y = loader.content.y;
            loader.content.x = 0;
            loader.content.y = 0;
        }

        /* INTERFACE cc.minos.bigbluebutton.playback.elements.IStep */

        public function inRange(time:Number):Boolean
        {
            if(time >= _inTime && time <= _outTime)
                return true;
            return false;
        }

        public function step(time:Number):void
        {
            for each (var s:ShapeElement in shapes)
            {
                s.step(time);
            }
        }

        public function set id(value:String):void
        {
            _id = value;
        }

        public function get id():String
        {
            return _id;
        }

        public function get inTime():Number
        {
            return _inTime;
        }

        public function set inTime(value:Number):void
        {
            if(isNaN(value))
            {
                _inTime = 0;
            }
            else
            {
                _inTime = value;
            }
        }

        public function get outTime():Number
        {
            return _outTime;
        }

        public function set outTime(value:Number):void
        {
            if(isNaN(value))
            {
                _outTime = Number.MAX_VALUE;
            }
            else
            {
                _outTime = value;
            }
        }

        public function get xml():XML
        {
            return _xml;
        }

        public function set xml(value:XML):void
        {
            _xml = value;
            init();
        }

        public function get imageHeight():Number
        {
            return _imageHeight;
        }

        public function set imageHeight(value:Number):void
        {
            _imageHeight = value;
        }

        public function get imageWidth():Number
        {
            return _imageWidth;
        }

        public function set imageWidth(value:Number):void
        {
            _imageWidth = value;
        }

        public function get type():String
        {
            return _type;
        }

        public function set type(value:String):void
        {
            _type = value;
        }

    }

}