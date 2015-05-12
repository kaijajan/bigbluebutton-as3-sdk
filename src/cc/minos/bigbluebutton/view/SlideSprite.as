package cc.minos.bigbluebutton.view {
    import cc.minos.bigbluebutton.models.Annotation;
    import cc.minos.bigbluebutton.plugins.present.Slide;
    import cc.minos.bigbluebutton.view.models.SlideViewModel;
    import cc.minos.bigbluebutton.view.shapes.DrawObject;
    import cc.minos.bigbluebutton.view.shapes.GraphicObject;
    import cc.minos.bigbluebutton.view.shapes.Pencil;
    import cc.minos.bigbluebutton.view.shapes.TextDrawObject;
    import cc.minos.bigbluebutton.view.shapes.TextObject;

    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.system.SecurityDomain;
    import flash.text.TextField;
    import flash.text.TextFormat;

    /**
     * ...
     * @author Minos
     */
    public class SlideSprite extends Sprite implements IWhiteboardCanvas {

        public var regionX:Number = 0;
        public var regionY:Number = 0;
        public var regionW:Number = 100;
        public var regionH:Number = 100;
        public var zoompercentage:Number = 100;
        public var page:Number = -1;

        public var synced:Boolean = false;

        protected var _width:Number = 1;
        protected var _height:Number = 1;

        protected var progressTf:TextField;
        protected var loader:Loader;
        protected var shape:Shape;

        protected var slide:Slide;

        protected var shapesContainer:Sprite;
        protected var _shapes:Array;

        public function SlideSprite(slide:Slide)
        {
            addChild(shape = new Shape());

            progressTf = new TextField();
            progressTf.defaultTextFormat = new TextFormat("Consolas", 12, 0, true);
            progressTf.autoSize = "left";
            progressTf.selectable = false;
            progressTf.text = "loading";
            addChild(progressTf);

            loader = new Loader();
            this.slide = slide;

            page = slide.slideNumber;
            slide.load(onDataComplete);

            _shapes = [];

            shapesContainer = new Sprite();
            shapesContainer.mouseChildren = false
            shapesContainer.mouseEnabled = false;
            addChild(shapesContainer);
        }

        private function onDataComplete(num:Number, data:*):void
        {
            progressTf.text = "complete";
            removeChild(progressTf);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
            //var c:LoaderContext = new LoaderContext( false, ApplicationDomain.currentDomain );
            //c.allowCodeImport = true;
            loader.loadBytes(data);
        }

        private function onComplete(e:Event):void
        {
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
            addChildAt(loader, 0);
            _width = loader.content.width;
            _height = loader.content.height;
            //removeChild( progressTf );
            dispatchEvent(e);
        }

        public function zoom(x:Number, y:Number, w:Number, h:Number):void
        {

            loader.x = x;
            loader.y = y;
            loader.width = w;
            loader.height = h;

            this.x = loader.x;
            this.y = loader.y;
            this.width = loader.width;
            this.height = loader.height;

            shape.x = loader.x;
            shape.y = loader.y;
            shapesContainer.x = loader.x;
            shapesContainer.y = loader.y;
            redrawGraphics();

            //
            progressTf.x = this.width - progressTf.width >> 1;
            progressTf.y = this.height - progressTf.height >> 1;
        }

        private function redrawGraphics():void
        {
            for(var i:int = 0; i < _shapes.length; i++)
            {
                var gobj:GraphicObject = _shapes[ i ];
                if(!gobj)
                    break;

                if(gobj.type == DrawObject.TEXT)
                {
                    var tobj:TextObject = gobj as TextObject;
                    tobj.redrawText(tobj.oldParentWidth, tobj.oldParentHeight, this.width, this.height);
                }
                else
                {
                    ( gobj as DrawObject ).redraw(( gobj as DrawObject ).annotation, this.width, this.height);
                }

            }
        }

        override public function get mouseX():Number
        {
            return shape.mouseX;
        }

        override public function get mouseY():Number
        {
            return shape.mouseY;
        }

        override public function get width():Number
        {
            return _width;
        }

        override public function set width(value:Number):void
        {
            if(_width != value)
            {
                _width = value;
                draw();
            }
        }

        override public function get height():Number
        {
            return _height;
        }

        override public function set height(value:Number):void
        {
            if(_height != value)
            {
                _height = value;
                draw();
            }
        }

        private function draw():void
        {
            shape.graphics.clear();
            shape.graphics.beginFill(0xff0000, 0);
            shape.graphics.drawRect(0, 0, _width, _height);
            shape.graphics.endFill();
        }

        /* cc.minos.bigbluebutton.view.IWhiteboardCanvas */

        public function addGraphic(g:GraphicObject):void
        {
            shapesContainer.addChild(g as DisplayObject);
            _shapes.push(g);
        }

        public function removeGraphic(g:GraphicObject):void
        {
            var obj:Object = getGraphicById(g.id);
            if(obj != null)
            {
                shapesContainer.removeChild(obj.graphic);
                _shapes.splice(obj.index, 1);
            }
        }

        public function getGraphicById(id:String):Object
        {
            for(var i:int = 0; i < _shapes.length; i++)
            {
                if(( _shapes[ i ] as GraphicObject ).id == id)
                {
                    return { index: i, graphic: _shapes[ i ] as GraphicObject };
                }
            }
            return null;
        }

        public function undo():void
        {
            if(_shapes.length > 0)
            {
                removeGraphic(_shapes[_shapes.length - 1]);
            }
        }

        public function clear():void
        {
            _shapes.length = 0;
            while(shapesContainer.numChildren > 0)
            {
                shapesContainer.removeChildAt(0);
            }
        }
    }

}