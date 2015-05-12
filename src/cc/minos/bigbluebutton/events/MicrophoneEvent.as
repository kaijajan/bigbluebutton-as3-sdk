package cc.minos.bigbluebutton.events {
    import flash.events.Event;

    /**
     * ...
     * @author Minos
     */
    public class MicrophoneEvent extends Event {
        public static const WARNING:String = "micWarning";

        public var data:Object = {};

        public function MicrophoneEvent(type:String)
        {
            super(type, true, false);
        }

        public override function clone():Event
        {
            var micEvt:MicrophoneEvent = new MicrophoneEvent(type);
            micEvt.data = data;
            return micEvt;
        }

    }

}