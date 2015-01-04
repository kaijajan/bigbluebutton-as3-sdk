package cc.minos.bigbluebutton.apis.resources {
    import flash.events.Event;

    /**
     * Join a new user to an existing meeting.
     * @author Minos
     */
    public class JoinResource extends Resource {
        public static var CALL_NAME:String = "join";

        protected var _fullName:String;
        protected var _password:String;
        protected var _createTime:String;
        protected var _userID:String;
        protected var _webVoiceConf:String;
        protected var _configToken:String;

        public function JoinResource(completedCallback:Function = null)
        {
            super(completedCallback);
            callName = CALL_NAME;
            requirs.push("fullName", "password");
        }

        override protected function onComplete(e:Event):void
        {
            var enterRes:EnterResource = new EnterResource(completedCallback);
            enterRes.call(host, securitySalt);
        }

        /**
         * The token returned by a setConfigXML API call.
         * This causes the BigBlueButton client to load the config.xml associated with the token (not the default config.xml)
         */
        public function get configToken():String
        {
            return _configToken;
        }

        public function set configToken(value:String):void
        {
            _configToken = value;
            setQuery("configToken", value);
        }

        /**
         * If you want to pass in a custom voice-extension when a user joins the voice conference using voip.
         * This is useful if you want to collect more info in you Call Detail Records about the user joining the conference.
         * You need to modify your /etc/asterisk/bbb-extensions.conf to handle this new extensions.
         */
        public function get webVoiceConf():String
        {
            return _webVoiceConf;
        }

        public function set webVoiceConf(value:String):void
        {
            _webVoiceConf = value;
            setQuery("webVoiceConf", value);
        }

        /**
         * An identifier for this user that will help your application to identify which person this is.
         * This user ID will be returned for this user in the getMeetingInfo API call so that you can check
         */
        public function get userID():String
        {
            return _userID;
        }

        public function set userID(value:String):void
        {
            _userID = value;
            setQuery("userID", value);
        }

        /**
         * Third-party apps using the API can now pass createTime parameter (which was created in the create call),
         * BigBlueButton will ensure it matches the ‘createTime’ for the session. If they differ,
         * BigBlueButton will not proceed with the join request.
         * This prevents a user from reusing their join URL for a subsequent session with the same meetingID.
         */
        public function get createTime():String
        {
            return _createTime;
        }

        public function set createTime(value:String):void
        {
            _createTime = value;
            setQuery("createTime", value);
        }

        /**
         * The password that this attendee is using. If the moderator password is supplied, he will be given moderator status (and the same for attendee password, etc)
         */
        public function get password():String
        {
            return _password;
        }

        public function set password(value:String):void
        {
            _password = value;
            setQuery("password", value);
        }

        /**
         * The full name that is to be used to identify this user to other conference attendees.
         */
        public function get fullName():String
        {
            return _fullName;
        }

        public function set fullName(value:String):void
        {
            _fullName = value;
            setQuery("fullName", value);
        }

    }

}