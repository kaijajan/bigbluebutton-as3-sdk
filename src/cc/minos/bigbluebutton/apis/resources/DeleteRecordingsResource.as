package cc.minos.bigbluebutton.apis.resources
{
	
	/**
	 * Delete one or more recordings for a given recordID (or set of record IDs).
	 * @author Minos
	 */
	public class DeleteRecordingsResource extends Resource
	{
		static public const CALL_NAME:String = "deleteRecordings";
		
		protected var _recordID:String;
		
		public function DeleteRecordingsResource( completedCallback:Function = null )
		{
			super( completedCallback );
			callName = CALL_NAME;
			requirs = [ "recordID" ];
		}
		
		/**
		 * A record ID for specify the recordings to delete. It can be a set of record IDs separated by commas.
		 */
		public function get recordID():String
		{
			return _recordID;
		}
		
		public function set recordID( value:String ):void
		{
			_recordID = value;
			setQuery( "recordID", value );
		}
	
	}

}