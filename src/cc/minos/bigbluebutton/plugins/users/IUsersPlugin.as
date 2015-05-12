package cc.minos.bigbluebutton.plugins.users {
    import cc.minos.bigbluebutton.models.IUsersList;
    import cc.minos.bigbluebutton.plugins.IPlugin;

    /**
     * ...
     * @author Minos
     */
    public interface IUsersPlugin extends IPlugin {
        function changeRecordingStatus(recording:Boolean):void;

        function assignPresenter(userID:String, name:String, assignedBy:Number):void

        function raiseHand(userID:String, raise:Boolean):void;

        function kickUser(userID:String):void;

        function ejectVoiceUser(voiceID:Number):void;

        function muteAllUsers(mute:Boolean, dontMuteThese:Array = null):void

        function muteUser(voiceID:Number, mute:Boolean):void

        function lockUser(voiceID:Number, lock:Boolean):void

        function addStream(userID:String, streamName:String):void

        function removeStream(userID:String, streamName:String):void

        function get usersList():IUsersList;
    }

}