package cc.minos.bigbluebutton.models {

    /**
     * ...
     * @author Minos
     */
    public interface IConfig {
        function get host():String;

        function get meetingID():String;

        function get role():String;

        function get securitySalt():String;

        function get username():String;

        function get record():String;

        function load(obj:Object):void;
    }

}