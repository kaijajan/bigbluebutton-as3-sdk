package cc.minos.bigbluebutton.playback.events {
    import flash.events.Event;

    /**
     * ...
     * @author Minos
     */
    public class PlayBackEvent extends Event {
        public static const UPDATE:String = "playback.update";
        public static const READY:String = "playback.ready";
        public static const STOP:String = "playback.stop";
        public static const PLAY:String = "playback.play";
        public static const PAUSE:String = "playback.pause";
        public static const CLEAR:String = "playback.clear";

        public var id:String;

        public function PlayBackEvent(type:String)
        {
            super(type, true, false);
        }

        public override function clone():Event
        {
            var cE:PlayBackEvent = new PlayBackEvent(type);
            cE.id = id;
            return cE;
        }

    }

}