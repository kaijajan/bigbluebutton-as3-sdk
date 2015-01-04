package cc.minos.bigbluebutton.apis.responses {

    /**
     * ...
     * @author Minos
     */
    public class EndResponse extends Response {

        public function EndResponse()
        {
            super();
        }

        public function get messageKey():String
        {
            return xml.messageKey;
        }

    }

}