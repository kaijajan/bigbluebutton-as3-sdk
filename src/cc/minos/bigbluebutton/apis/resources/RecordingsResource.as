package cc.minos.bigbluebutton.apis.resources
{
	
	/**
	 * Retrieves the recordings that are available for playback for a given meetingID (or set of meeting IDs).
	 * @author Minos
	 */
	public class RecordingsResource extends Resource
	{
		public static const CALL_NAME:String = "getRecordings";
		
		public function RecordingsResource( completedCallback:Function = null )
		{
			super( completedCallback );
			callName = CALL_NAME;
			requirs.length = 0;
		}
		
		/**
		 * A meeting ID for get the recordings.
		 * It can be a set of meetingIDs separate by commas.
		 * If the meeting ID is not specified, it will get ALL the recordings.
		 */
		override public function get meetingID():String
		{
			return super.meetingID;
		}
		
		override public function set meetingID( value:String ):void
		{
			super.meetingID = value;
		}
	
	}

}