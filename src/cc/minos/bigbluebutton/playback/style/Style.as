package cc.minos.bigbluebutton.playback.style {
    import cc.minos.bigbluebutton.playback.Constants;
    import cc.minos.bigbluebutton.playback.utils.StyleUtil;

    import flash.display.DisplayObject;
    import flash.display.CapsStyle;
    import flash.display.JointStyle;
    import flash.display.Sprite;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.text.engine.FontWeight;

    public class Style {
        public var id:String = "item";
        public var opacity:Number = 1.0;
        public var display:Boolean = true;
        public var rotate:Number;
        public var visibility:String;
        public var transform:Transform;
        public var viewBox:Rectangle;

        //paint
        public var stroke:uint = Constants.STROKE_COLOR;
        public var fill:uint = Constants.FILL_COLOR;
        public var stroke_opacity:Number = 1.0;
        public var stroke_width:Number = 1.0;
        public var stroke_miterlimit:Number = 3.0;
        public var stroke_linecap:String = CapsStyle.NONE;
        public var stroke_linejoin:String = JointStyle.ROUND;
        public var fill_opacity:Number = 1.0;
        public var fill_rule:String;
        public var marker:String;

        //text
        public var font_size:Number = Constants.FONT_SIZE;
        public var font_style:String;
        public var font_family:String = Constants.FONT_FAMILY;
        public var font_weight:String = Constants.FONT_WEIGHT;
        public var font_size_adjust:Number;
        public var font_stretch:String;
        public var font_variant:String;
        public var direction:String;
        public var letter_spacing:Number;
        public var word_spacing:Number;
        public var text_decoration:String;
        public var alignment_baseline:String;
        public var baseline_shift:Number;
        public var dominant_baseline:String;
        public var glyph_orientation_horizontal:int;
        public var glyph_orientation_vertical:int;
        public var kerning:Number;
        public var text_align:String;
        public var writing_mode:String;
        public var line_height:Number;
        public var fontLookup:String = Constants.FONT_LOOKUP; // for FontConverter

        //link id
        public var stroke_id:String;
        public var fill_id:String;
        public var filter_id:String;
        public var mask_id:String;
        public var clipPath_id:String;

        //gradation
        public var stop_color:uint = 0;
        public var stop_opacity:Number = 1;
        public var offset:Number = 0;
        public var href:String;
        public var gradientUnits:String;
        public var gradientTransform:Transform;

        private var _hasStroke:Boolean = false;
        private var _hasFill:Boolean = true;
        private var _hasGradientStroke:Boolean = false;
        private var _hasGradientFill:Boolean = false;
        private var _hasClipPath:Boolean = false;

        private var _xmls:XMLList = new XMLList();

        public function Style(xml:XML = null)
        {
            if(xml)
                parse(xml);
        }

        public function parse(xml:XML):void
        {
            _xmls += xml;
            var attr:XMLList = xml.@*;
            for each (var item:XML in attr)
                setStyle(item.name(), item.toString());
        }

        public function copy():Style
        {
            var style:Style = new Style();
            for each (var xml:XML in _xmls)
                style.addStyle(xml);
            return style;
        }

        public function addStyle(xml:XML):void
        {
            parse(xml);
        }

        /*public function applyStyle( d:DisplayObject, data:Data = null, setName:Boolean = true ):void
         {
         if ( setName )
         d.name = id;
         d.alpha = opacity;
         if ( viewBox )
         d.scrollRect = viewBox;
         if ( hasTransform )
         {
         var m:Matrix = d.transform.matrix.clone();
         m.concat( transform.getMatrix() );
         d.transform.matrix = m;
         }
         if ( hasFilter && data != null )
         {
         var fl:FilterSet = data.getFilterById( filter_id );
         if ( fl.hasFilter() )
         {
         fl.setSourceGraphic( d );
         d.filters = fl.getAllFilters();
         }
         }
         if ( hasClipPath && data != null )
         {
         var maskobj:DisplayObject = data.getClipPathById( clipPath_id );
         if ( maskobj )
         {
         var mtx:Matrix = maskobj.transform.matrix.clone();
         mtx.concat( getMatrix() );
         maskobj.transform.matrix = mtx;
         data.currentCanvas.addChild( maskobj );
         d.mask = maskobj;
         }
         }
         }*/

        public function getMatrix():Matrix
        {
            if(hasTransform)
                return transform.getMatrix();
            return new Matrix();
        }

        private function parseStyles(st:String):void
        {
            var styles:Array = st.split(";");
            for each (var item:String in styles)
            {
                var val:Array = item.split(":");
                setStyle(val[ 0 ], val[ 1 ]);
            }
        }

        private function setStyle(key:String, val:String):void
        {
            key = key.replace(/-/g, "_");
            if(key.indexOf("http://") != -1)
                key = StyleUtil.removeNameSpace(key);
            switch(key)
            {
                case "stroke":
                    if(val.indexOf("url") == -1)
                    {
                        stroke = StyleUtil.toColor(val);
                    }
                    else
                    {
                        stroke_id = StyleUtil.toURL(val);
                        _hasGradientStroke = true;
                    }
                    _hasStroke = ( val != "none" );
                    break;
                case "fill":
                    if(val == "none")
                        _hasFill = false;
                    else if(val.indexOf("url") == -1)
                    {
                        fill = StyleUtil.toColor(val);
                        _hasFill = true;
                    }
                    else
                    {
                        fill_id = StyleUtil.toURL(val);
                        _hasGradientFill = true;
                    }
                    break;
                case "stroke_width":
                    stroke_width = StyleUtil.toNumber(val);
                    break;
                case "stroke_linecap":
                    stroke_linecap = ( val == CapsStyle.SQUARE || val == CapsStyle.ROUND ) ? val : CapsStyle.NONE;
                    break;
                case "font_family":
                    font_family = val.replace(/\'/g, "");
                    break;
                case "font_size":
                    font_size = StyleUtil.toNumber(val);
                    break;
                case "font_weight":
                    font_weight = ( val != FontWeight.NORMAL && val != FontWeight.BOLD ) ? FontWeight.NORMAL : val;
                    break;
                case "display":
                    display = ( val.toString() != "none" );
                    break;
                case "transform":
                    transform = new Transform(val);
                    break;
                case "style":
                    parseStyles(val);
                    break;
                case "filter":
                    filter_id = StyleUtil.toURL(val);
                    break;
                case "clip_path":
                    clipPath_id = StyleUtil.toURL(val);
                    _hasClipPath = true;
                    break;
                case "viewBox":
                    var values:Array = val.split(" ");
                    viewBox = new Rectangle(values[ 0 ], values[ 1 ], values[ 2 ], values[ 3 ]);
                    break;
                case "text_align":
                    text_align = val;
                    break;
                //Gradients
                case "stop_color":
                    stop_color = StyleUtil.toColor(val);
                    break;
                case "href":
                    href = val.replace(/^#/, "");
                    break;
                case "gradientTransform":
                    gradientTransform = new Transform(val);
                    break;
                default:
                    if(this.hasOwnProperty(key))
                    {
                        switch(typeof( this[ key ] ))
                        {
                            case "string":
                                this[ key ] = val;
                                break;
                            case "number":
                                this[ key ] = StyleUtil.toNumber(val);
                                break;
                        }
                    }
                    break;
            }
        }

        public function get hasStroke():Boolean
        {
            return _hasStroke && stroke_width != 0;
        }

        public function get hasFill():Boolean
        {
            return _hasFill;
        }

        public function get hasGradientStroke():Boolean
        {
            return _hasGradientStroke;
        }

        public function get hasGradientFill():Boolean
        {
            return _hasGradientFill;
        }

        public function get hasFilter():Boolean
        {
            return ( filter_id != null );
        }

        public function get hasTransform():Boolean
        {
            return ( transform != null );
        }

        public function get hasClipPath():Boolean
        {
            return _hasClipPath;
        }
    }

}