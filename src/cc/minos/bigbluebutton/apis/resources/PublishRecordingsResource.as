package cc.minos.bigbluebutton.apis.resources {

    /**
     * Publish and unpublish recordings for a given recordID (or set of record IDs).
     * @author Minos
     */
    public class PublishRecordingsResource extends Resource {
        static public const CALL_NAME:String = "publishRecordings";

        protected var _publish:String;
        protected var _recordID:String;

        public function PublishRecordingsResource(completedCallback:Function = null)
        {
            super(completedCallback);
            callName = CALL_NAME;
            requirs = [ "recordID", "publish" ];
        }

        /**
         * A record ID for specify the recordings to apply the publish action.
         * It can be a set of record IDs separated by commas.
         */
        public function get recordID():String
        {
            return _recordID;
        }

        public function set recordID(value:String):void
        {
            _recordID = value;
            setQuery("recordID", value);
        }

        /**
         * The value for publish or unpublish the recording(s).
         * Available values: true or false.
         */
        public function get publish():String
        {
            return _publish;
        }

        public function set publish(value:String):void
        {
            _publish = value;
            setQuery("publish", value);
        }

    }

}