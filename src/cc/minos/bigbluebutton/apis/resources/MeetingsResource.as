package cc.minos.bigbluebutton.apis.resources
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public class MeetingsResource extends Resource
	{
		static public const CALL_NAME:String = "getMeetings";
		
		public function MeetingsResource( completedCallback:Function = null )
		{
			super( completedCallback );
			callName = CALL_NAME;
			requirs.length = 0;
			
		}
	
	}

}