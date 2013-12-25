package cc.minos.bigbluebutton.models
{
	import flash.net.NetConnection;
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IConferenceParameters
	{
		function get meetingName():String;
		function set meetingName( meetingName:String ):void;
		function get externMeetingID():String;
		function set externMeetingID( externMeetingID:String ):void;
		function get conference():String;
		function set conference( conference:String ):void;
		function get username():String;
		function set username( username:String ):void;
		function get role():String;
		function set role( role:String ):void;
		function get room():String;
		function set room( room:String ):void;
		function get webvoiceconf():String;
		function set webvoiceconf( webvoiceconf:String ):void;
		function get voicebridge():String;
		function set voicebridge( voicebridge:String ):void;
		function get welcome():String;
		function set welcome( welcome:String ):void;
		function get externUserID():String;
		function set externUserID( externUserID:String ):void;
		function get internalUserID():String;
		function set internalUserID( internalUserID:String ):void;
		function get logoutUrl():String;
		function set logoutUrl( logoutUrl:String ):void;
		function get connection():NetConnection;
		function set connection( connection:NetConnection ):void;
		function get userid():String;
		function set userid( userid:String ):void;
		function get record():Boolean;
		function set record( record:Boolean ):void;
		function load( obj:Object ):void;
	}

}