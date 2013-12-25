
package cc.minos.bigbluebutton.core
{
	import flash.media.Microphone;
	import flash.net.NetConnection;
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IVoiceConnection
	{
		
		function connect( uri:String, externUID:String, voicename:String, dial:String, mic:Microphone ):void;
		function disconnect( userCommand:Boolean ):void;
		function failedToJoinVoiceConferenceCallback( message:String ):*;
		function disconnectedFromJoinVoiceConferenceCallback( message:String ):*;
		function successfullyJoinedVoiceConferenceCallback( publishName:String, playName:String, codec:String ):*;
		function call():void;
		function hangup():void;
		
		function get connection():NetConnection;
	
	}
}