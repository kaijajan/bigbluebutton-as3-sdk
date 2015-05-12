package cc.minos.bigbluebutton.apis.responses {

    /**
     * ...
     * @author Minos
     */
    public class MeetingInfoResponses extends CreateResponse {

        public function MeetingInfoResponses()
        {
            super();
        }

        public function get meetingName():String
        {
            return xml.meetingName;
        }

        public function get voiceBridge():String
        {
            return xml.voiceBridge;
        }

        public function get running():Boolean
        {
            return ( xml.running.toString() == "true" );
        }

        public function get recording():Boolean
        {
            return ( xml.recording.toString() == "true" );
        }

        public function get startTime():Number
        {
            return Number(xml.startTime);
        }

        public function get endTime():Number
        {
            return Number(xml.endTime);
        }

        public function get participantCount():Number
        {
            return Number(xml.participantCount);
        }

        public function get maxUsers():Number
        {
            return Number(xml.maxUsers);
        }

        public function get moderatorCount():Number
        {
            return Number(xml.moderatorCount);
        }

    }

}