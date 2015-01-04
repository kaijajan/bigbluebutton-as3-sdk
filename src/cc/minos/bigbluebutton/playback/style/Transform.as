package cc.minos.bigbluebutton.playback.style {
    import cc.minos.bigbluebutton.playback.utils.GeomUtil;

    import flash.display.DisplayObject;
    import flash.geom.Matrix;

    public class Transform {

        public var type:String;
        private var vals:Array;
        private var _matrix:Matrix;

        public function Transform(str:String = null)
        {
            _matrix = new Matrix();
            if(str != null) parse(str);
        }

        public function parse(str:String):void
        {
            type = str.replace(/(.+)\(.+\)/, "$1");
            if(str.indexOf(",") != -1) vals = str.replace(/.+\((.+)\)/, "$1").split(",");
            else if(str.indexOf(" ") != -1) vals = str.replace(/.+\((.+)\)/, "$1").split(" ");
            else  vals = [ Number(str.replace(/.+\((.+)\)/, "$1")) ];
            switch(type)
            {
                case "matrix" :
                    _matrix = new Matrix(vals[0], vals[1], vals[2], vals[3], vals[4], vals[5]);
                    break;
                case "translate" :
                    _matrix.translate(vals[0], vals[1]);
                    break;
                case "scale" :
                    if(vals.length < 2) vals.push(vals[0]);
                    _matrix.scale(vals[0], vals[1]);
                    break;
                case "rotate":
                    _matrix.rotate(GeomUtil.degree2radian(vals[0]));
                    break;
                case "skewX":
                    _matrix.c = Math.tan(GeomUtil.degree2radian(vals[0]));
                    break;
                case "skewY":
                    _matrix.b = Math.tan(GeomUtil.degree2radian(vals[0]));
                    break;
            }
        }

        public function getMatrix():Matrix
        {
            return _matrix;
        }
    }

}