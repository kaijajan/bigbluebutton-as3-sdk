package cc.minos.bigbluebutton.apis.responses
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public class CreateResponse extends Response
	{
		
		public function CreateResponse()
		{
			super();
		}
		
		public function get meetingID():String
		{
			return xml.meetingID;
		}
		
		public function get createTime():String
		{
			return xml.createTime;
		}
		
		public function get attendeePW():String
		{
			return xml.attendeePW;
		}
		
		public function get moderatorPW():String
		{
			return xml.moderatorPW;
		}
		
		public function get hasBeenForciblyEnded():Boolean
		{
			return ( xml.hasBeenForciblyEnded.toString() == "true" );
		}
		
		public function get messageKey():String
		{
			return xml.messageKey;
		}
		
		/*public function get message():String
		{
			return xml.message;
		}*/
	
	}

}