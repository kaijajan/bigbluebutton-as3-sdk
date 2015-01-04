package cc.minos.bigbluebutton.apis.responses {

    /**
     * ...
     * @author Minos
     */
    public class RunningResponse extends Response {

        public function RunningResponse()
        {
            super();
        }

        /**
         * running can be “true” or “false” that signals whether a meeting with this ID is currently running.
         */
        public function get running():Boolean
        {
            return ( xml.running.toString() == "true" );
        }

    }

}