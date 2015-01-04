package cc.minos.bigbluebutton.models {
    import flash.net.NetConnection;

    /**
     * ...
     * @author Minos
     */
    public class ConferenceParameters implements IConferenceParameters {
        private var _record:Boolean;
        private var _meetingName:String;
        private var _externMeetingID:String;
        private var _conference:String;
        private var _username:String;
        private var _role:String;
        private var _room:String;
        private var _webvoiceconf:String;
        private var _voicebridge:String;
        private var _welcome:String;
        private var _externUserID:String;
        private var _userid:String;
        private var _connection:NetConnection;
        private var _logoutUrl:String;
        private var _internalUserID:String;

        public function ConferenceParameters()
        {
        }

        /* INTERFACE cc.minos.bigbluebutton.model.IConferenceParameters */

        public function get meetingName():String
        {
            return _meetingName;
        }

        public function set meetingName(value:String):void
        {
            _meetingName = value;
        }

        public function get externMeetingID():String
        {
            return _externMeetingID;
        }

        public function set externMeetingID(value:String):void
        {
            _externMeetingID = value;
        }

        public function get conference():String
        {
            return _conference;
        }

        public function set conference(value:String):void
        {
            _conference = value;
        }

        public function get username():String
        {
            return _username;
        }

        public function set username(value:String):void
        {
            _username = value;
        }

        public function get role():String
        {
            return _role;
        }

        public function set role(value:String):void
        {
            _role = value;
        }

        public function get room():String
        {
            return _room;
        }

        public function set room(value:String):void
        {
            _room = value;
        }

        public function get webvoiceconf():String
        {
            return _webvoiceconf;
        }

        public function set webvoiceconf(value:String):void
        {
            _webvoiceconf = value;
        }

        public function get voicebridge():String
        {
            return _voicebridge;
        }

        public function set voicebridge(value:String):void
        {
            _voicebridge = value;
        }

        public function get welcome():String
        {
            return _welcome;
        }

        public function set welcome(value:String):void
        {
            _welcome = value;
        }

        public function get externUserID():String
        {
            return _externUserID;
        }

        public function set externUserID(value:String):void
        {
            _externUserID = value;
        }

        public function get internalUserID():String
        {
            return _internalUserID;
        }

        public function set internalUserID(value:String):void
        {
            _internalUserID = value;
        }

        public function get logoutUrl():String
        {
            return _logoutUrl;
        }

        public function set logoutUrl(value:String):void
        {
            _logoutUrl = value;
        }

        public function get connection():NetConnection
        {
            return _connection;
        }

        public function set connection(value:NetConnection):void
        {
            _connection = value;
        }

        public function get userid():String
        {
            return _userid;
        }

        public function set userid(value:String):void
        {
            _userid = value;
        }

        public function get record():Boolean
        {
            return _record;
        }

        public function set record(value:Boolean):void
        {
            _record = value;
        }

        public function load(obj:Object):void
        {
        }

    }

}