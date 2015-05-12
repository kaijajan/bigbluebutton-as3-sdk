package cc.minos.bigbluebutton.events {
    import flash.events.Event;

    /**
     * ...
     * @author Minos
     */
    public class BigBlueButtonEvent extends Event {
        public static const END_MEETING:String = "endMeeting";
        public static const CHANGE_RECORDING_STATUS:String = "changeRecordingStatus";
        public static const USER_LOGIN:String = "userLogin";
        public static const USER_LOGOUT:String = "userLogout";

        public static const ERROR:String = 'bbbError';

        public var data:Object = {};

        public function BigBlueButtonEvent(type:String)
        {
            super(type, false, false);
        }

        public override function clone():Event
        {
            var cEvent:BigBlueButtonEvent = new BigBlueButtonEvent(type);
            cEvent.data = data;
            return cEvent;
        }

    }

}