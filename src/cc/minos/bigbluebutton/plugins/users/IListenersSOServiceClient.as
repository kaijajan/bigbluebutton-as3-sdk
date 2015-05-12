package cc.minos.bigbluebutton.plugins.users {

    /**
     * ...
     * @author Minos
     */
    public interface IListenersSOServiceClient {

        ///////////////////////
        // METHODS
        ///////////////////////
        function ping(message:String):void

        function userLeft(voiceID:Number):void;

        function userTalk(voiceID:Number, talk:Boolean):void;

        function userLockedMute(voiceID:Number, locked:Boolean):void;

        function userMute(voiceID:Number, mute:Boolean):void;

        function userJoin(voiceID:Number, cidName:String, cidNum:String, muted:Boolean, talking:Boolean, locked:Boolean):void;

        function muteStateCallback(mute:Boolean):void
    }
}