package cc.minos.bigbluebutton.plugins.users {

    /**
     * ...
     * @author Minos
     */
    public interface IParticipantsSOServiceClient {
        function logout():void;

        function participantJoined(joinedUser:Object):void;

        function participantLeft(userID:String):void;

        function assignPresenterCallback(userID:String, name:String, assignedBy:String):void;

        function kickUserCallback(userID:String):void;

        function participantStatusChange(userID:String, status:String, value:Object):void;
    }
}