package cc.minos.bigbluebutton.events {
    import flash.events.Event;

    /**
     * ...
     * @author Minos
     */
    public class VoiceConferenceEvent extends Event {
        public static const JOINED:String = 'successfullyJoined';
        public static const FAILED:String = 'failedToJoin';
        public static const DISCONNECTED:String = 'disconnectedFromJoin';

        public function VoiceConferenceEvent(type:String)
        {
            super(type, true, false);
        }

        public override function clone():Event
        {
            return new VoiceConferenceEvent(type);
        }

        public override function toString():String
        {
            return formatToString("VoiceConferenceEvent", "type", "bubbles", "cancelable", "eventPhase");
        }

    }

}