package cc.minos.bigbluebutton.playback.steps
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IStep
	{
		function get type():String;
		function set type( value:String ):void;
		function get id():String;
		function set id( value:String ):void;
		function get inTime():Number;
		function set inTime( value:Number ):void;
		function get outTime():Number;
		function set outTime( value:Number ):void;
		function inRange( time:Number ):Boolean;
		function step( time:Number ):void;
		function set xml( value:XML ):void;
		function get xml():XML;
	}

}