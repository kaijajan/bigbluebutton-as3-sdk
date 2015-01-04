package cc.minos.bigbluebutton.events {
    import flash.events.Event;

    /**
     * ...
     * @author Minos
     */
    public class ConnectionFailedEvent extends Event {

        /** 未知錯誤 */
        public static const UNKNOWN_REASON:String = "unknownReason";
        /** 連接失敗 */
        //public static const CONNECTION_FAILED:String = "connectionFailed";
        /** 連接關閉 */
        public static const CONNECTION_CLOSED:String = "connectionClosed";
        /** 無效服務 */
        public static const INVALID_APP:String = "invalidApp";
        /** 服務關閉 */
        public static const APP_SHUTDOWN:String = "appShutdown";
        /** 連接被拒絕 */
        public static const CONNECTION_REJECTED:String = "connectionRejected";
        /** 同步錯誤 */
        public static const ASYNC_ERROR:String = "asyncError";

        public static const FAILED:String = "connectionFailed";

        public var reason:String;

        public function ConnectionFailedEvent()
        {
            super(FAILED, false, false);
        }

        public override function clone():Event
        {
            var evt:ConnectionFailedEvent = new ConnectionFailedEvent();
            evt.reason = reason;
            return evt;
        }

    }

}