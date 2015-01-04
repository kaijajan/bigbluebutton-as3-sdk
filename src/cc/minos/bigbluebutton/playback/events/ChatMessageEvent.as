package cc.minos.bigbluebutton.playback.events {
    import flash.events.Event;

    /**
     * ...
     * @author Minos
     */
    public class ChatMessageEvent extends Event {
        static public const ADD:String = "playback.message.add";

        public var direction:String;
        public var name:String;
        public var message:String;

        public function ChatMessageEvent()
        {
            super(ADD, true, false);
        }

        public override function clone():Event
        {
            var cE:ChatMessageEvent = new ChatMessageEvent();
            cE.direction = direction;
            cE.name = name;
            cE.message = message;
            return cE;
        }

    }

}