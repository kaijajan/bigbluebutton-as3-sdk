package cc.minos.bigbluebutton.playback.steps {
    import cc.minos.bigbluebutton.playback.events.ZoomEvent;

    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.geom.Rectangle;

    /**
     * ...
     * @author Minos
     */
    public class EventStep extends EventDispatcher implements IStep {
        protected var _outTime:Number = Number.MAX_VALUE;
        protected var _inTime:Number = 0;
        protected var _id:String;
        protected var _xml:XML;
        protected var _type:String = "event";
        protected var eventNode:String = "event";
        protected var timeNode:String = "timestamp";

        public function EventStep(xml:XML = null)
        {
            if(xml != null)
                this.xml = xml;
        }

        protected function init():void
        {
            this.id = this.xml.@id;
            var list:XMLList = this.xml[ eventNode ];
            if(list.length() > 0)
            {
                inTime = list[ 0 ].@[ timeNode ];
                outTime = list[ list.length() - 1 ].@[ timeNode ];
            }
        }

        protected function sendStepEvent(step:XML):void
        {
        }

        /* INTERFACE cc.minos.bigbluebutton.playback.elements.IStep */

        public function inRange(time:Number):Boolean
        {
            if(time >= inTime && time <= outTime)
                return true;
            return false;
        }

        public function step(time:Number):void
        {
            var list:XMLList = xml[ eventNode ].( @[timeNode] == time );

            if(list.length() > 0)
            {
                var __xml:XML = list[ 0 ];
                sendStepEvent(__xml);
            }
        }

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