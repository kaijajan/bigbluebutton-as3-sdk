package cc.minos.bigbluebutton.apis.resources {
    import cc.minos.bigbluebutton.apis.responses.RunningResponse;

    /**
     * ...
     * @author Minos
     */
    public class RunningResoure extends Resource {
        static public const CALL_NAME:String = "isMeetingRunning";

        public function RunningResoure(completedCallback:Function = null)
        {
            super(completedCallback);
            callName = CALL_NAME;
            response = new RunningResponse();
        }

    }

}