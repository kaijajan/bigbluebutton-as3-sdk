package cc.minos.bigbluebutton.models {

    /**
     * ...
     * @author Minos
     */
    public class BBBUser extends Object {
        ///////////////////////
        // PROPERTIES
        ///////////////////////

        public var userID:String;
        public var externUserID:String;
        public var name:String;
        public var me:Boolean = false;
        private var _talking:Boolean = false;
        private var _hasStream:Boolean = false;
        public var role:String;
        public var voiceUserID:Number;
        private var _voiceJoined:Boolean = false;
        private var _voiceMuted:Boolean = false;
        private var _voiceLocked:Boolean = false;
        private var _raiseHand:Boolean = false;
        private var _presenter:Boolean = false;
        public var streamName:String;

        public var isLeavingFlag:Boolean = false;


        public function BBBUser()
        {
        }

        public function get talking():Boolean
        {
            return _talking;
        }

        public function set talking(value:Boolean):void
        {
            _talking = value;
        }

        public function get hasStream():Boolean
        {
            return _hasStream;
        }

        public function set hasStream(value:Boolean):void
        {
            _hasStream = value;
        }

        public function get voiceJoined():Boolean
        {
            return _voiceJoined;
        }

        public function set voiceJoined(value:Boolean):void
        {
            _voiceJoined = value;
        }

        public function get voiceMuted():Boolean
        {
            return _voiceMuted;
        }

        public function set voiceMuted(value:Boolean):void
        {
            _voiceMuted = value;
        }

        public function get voiceLocked():Boolean
        {
            return _voiceLocked;
        }

        public function set voiceLocked(value:Boolean):void
        {
            _voiceLocked = value;
        }

        public function get raiseHand():Boolean
        {
            return _raiseHand;
        }

        public function set raiseHand(value:Boolean):void
        {
            _raiseHand = value;
        }

        public function get presenter():Boolean
        {
            return _presenter;
        }

        public function set presenter(value:Boolean):void
        {
            _presenter = value;
        }

        public function toString():String
        {
            return userID;
        }
    }
}