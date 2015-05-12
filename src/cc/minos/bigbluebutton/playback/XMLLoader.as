package cc.minos.bigbluebutton.playback {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.net.URLLoader;
    import flash.net.URLRequest;

    /**
     * ...
     * @author Minos
     */
    public class XMLLoader extends EventDispatcher {
        private var _url:String;
        private var _xml:XML;
        private var _id:String;

        private var loader:URLLoader;

        public function XMLLoader(url:String = null)
        {
            if(url != null)
                load(url);
        }

        public function load(url:String):void
        {
            this.url = url;

            if(loader)
                loader.close();
            loader = new URLLoader();
            loader.addEventListener(Event.COMPLETE, onComplete);
            loader.load(new URLRequest(url));
        }

        private function onComplete(e:Event):void
        {
            xml = new XML(loader.data);
            dispatchEvent(e);
        }

        public function get url():String
        {
            return _url;
        }

        public function set url(value:String):void
        {
            _url = value;
        }

        public function get xml():XML
        {
            return _xml;
        }

        public function set xml(value:XML):void
        {
            _xml = value;
        }

        public function get id():String
        {
            return _id;
        }

        public function set id(value:String):void
        {
            _id = value;
        }

    }

}