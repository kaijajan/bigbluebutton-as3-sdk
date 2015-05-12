package cc.minos.bigbluebutton.plugins.voice {

    /**
     * ...
     * @author Minos
     */
    public interface IVoicePlugin {
        function join(withMic:Boolean):void

        function hangup():void;
    }

}