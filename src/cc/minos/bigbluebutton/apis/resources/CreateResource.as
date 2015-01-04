package cc.minos.bigbluebutton.apis.resources {
    import cc.minos.bigbluebutton.apis.responses.CreateResponse;

    /**
     * Creates a new meeting.
     * @author Minos
     */
    public class CreateResource extends Resource {
        public static const CALL_NAME:String = "create";

        protected var _name:String;
        protected var _attendeePW:String;
        protected var _moderatorPW:String;
        protected var _welcome:String;
        protected var _dialNumber:String;
        protected var _voiceBridge:String;
        protected var _webVoice:String;
        protected var _logoutURL:String;
        protected var _record:String;
        protected var _duration:Number;
        protected var _meta:String;

        public function CreateResource(completedCallback:Function = null)
        {
            super(completedCallback);
            callName = CALL_NAME;
            response = new CreateResponse();
        }

        /**
         * A name for the meeting.
         */
        public function get name():String
        {
            return _name;
        }

        public function set name(value:String):void
        {
            _name = value;
            setQuery("name", value);
        }

        /**
         * The password that will be required for attendees to join the meeting.
         * This is optional, and if not supplied, BBB will assign a random password.
         */
        public function get attendeePW():String
        {
            return _attendeePW;
        }

        public function set attendeePW(value:String):void
        {
            _attendeePW = value;
            setQuery("attendeePW", value);
        }

        /**
         * The password that will be required for moderators to join the meeting or for certain administrative actions (i.e. ending a meeting). This is optional, and if not supplied, BBB will assign a random password.
         */
        public function get moderatorPW():String
        {
            return _moderatorPW;
        }

        public function set moderatorPW(value:String):void
        {
            _moderatorPW = value;
            setQuery("moderatorPW", value);
        }

        /**
         * A welcome message that gets displayed on the chat window when the participant joins. You can include keywords (%%CONFNAME%%, %%DIALNUM%%, %%CONFNUM%%) which will be substituted automatically.
         * You can set a default welcome message on bigbluebutton.properties (https://github.com/bigbluebutton/bigbluebutton/blob/master/bigbluebutton-web/grails-app/conf/bigbluebutton.properties)
         */
        public function get welcome():String
        {
            return _welcome;
        }

        public function set welcome(value:String):void
        {
            _welcome = value;
            setQuery("welcome", value);
        }

        /**
         * The dial access number that participants can call in using regular phone.
         * You can set a default dial number on bigbluebutton.properties (https://github.com/bigbluebutton/bigbluebutton/blob/master/bigbluebutton-web/grails-app/conf/bigbluebutton.properties)
         */
        public function get dialNumber():String
        {
            return _dialNumber;
        }

        public function set dialNumber(value:String):void
        {
            _dialNumber = value;
            setQuery("dialNumber", value);
        }

        /**
         * Voice conference number that participants enter to join the voice conference.
         * The default pattern for this is a 5-digit number, because in the default Asterisk configuration, this is the PIN that a dial-in user must enter to join the conference.
         * If you want to change this pattern, you have to edit /etc/asterisk/bbb_extensions.conf. When using the default setup, we recommend you always pass a 5 digit voiceBridge parameter -- and have it begin with the digit '7' if you are using the default FreeSWITCH setup.
         * Finally, if you don't pass a value for voiceBridge, then users will not be able to join a voice conference for the session.
         */
        public function get voiceBridge():String
        {
            return _voiceBridge;
        }

        public function set voiceBridge(value:String):void
        {
            _voiceBridge = value;
            setQuery("voiceBridge", value);
        }

        /**
         * Voice conference alphanumberic that participants enter to join the voice conference.
         */
        public function get webVoice():String
        {
            return _webVoice;
        }

        public function set webVoice(value:String):void
        {
            _webVoice = value;
            setQuery("webVoice", value);
        }

        /**
         * The URL that the BigBlueButton client will go to after users click the OK button on the 'You have been logged out message'.
         * This overrides, the value for bigbluebutton.web.loggedOutURL if defined in bigbluebutton.properties (https://github.com/bigbluebutton/bigbluebutton/blob/master/bigbluebutton-web/grails-app/conf/bigbluebutton.properties)
         */
        public function get logoutURL():String
        {
            return _logoutURL;
        }

        public function set logoutURL(value:String):void
        {
            _logoutURL = value;
            setQuery("logoutURL", value);
        }

        /**
         * Setting ‘record=true’ instructs the BigBlueButton server to record the media and events in the session for later playback. Available values are true or false. Default value is false.
         */
        public function get record():String
        {
            return _record;
        }

        public function set record(value:String):void
        {
            _record = value;
            setQuery("record", value);
        }

        /**
         * The duration parameter allows to specify the number of minutes for the meeting's length.
         * When the length of the meeting reaches the duration, BigBlueButton automatically ends the meeting.
         * The default is 0, which means the meeting continues until the last person leaves or an end API calls is made with the associated meetingID.
         */
        public function get duration():Number
        {
            return _duration;
        }

        public function set duration(value:Number):void
        {
            _duration = value;
            setQuery("duration", value + "");
        }

        /**
         * You can pass one or more metadata values for create a meeting.
         * These will be stored by BigBlueButton and later retrievable via the getMeetingInfo call and getRecordings.
         * Examples of meta parameters are meta_Presenter, meta_category, meta_LABEL, etc.
         * All parameters are converted to lower case, so meta_Presenter would be the same as meta_PRESENTER.
         */
        public function get meta():String
        {
            return _meta;
        }

        public function set meta(value:String):void
        {
            _meta = value;
            setQuery("meta", value);
        }

    }

}