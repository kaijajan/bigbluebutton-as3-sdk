package cc.minos.bigbluebutton.apis.responses
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public class JoinResponse extends Response
	{
		
		public function JoinResponse()
		{
			super();
		}
		
		public function get fullname():String
		{
			return xml.fullname;
		}
		
		public function get conference():String
		{
			return xml.conference;
		}
		
		public function get externMeetingID():String
		{
			return xml.externMeetingID;
		}
		
		public function get meetingID():String
		{
			return xml.meetingID;
		}
		
		public function get externUserID():String
		{
			return xml.externUserID;
		}
		
		public function get internalUserID():String
		{
			return xml.internalUserID;
		}
		
		public function get role():String
		{
			return xml.role;
		}
		
		public function get room():String
		{
			return xml.room;
		}
		
		public function get authToken():String
		{
			return xml.room;
		}
		
		public function get record():Boolean
		{
			return ( xml.record.toString() == "true" );
		}
		
		public function get webvoiceconf():String
		{
			return xml.webvoiceconf;
		}
		
		public function get dialnumber():Number
		{
			return Number( xml.dialnumber );
		}
		
		public function get voicebridge():String
		{
			return xml.voicebridge;
		}
		
		public function get mode():String
		{
			return xml.mode;
		}
		
		public function get welcome():String
		{
			return xml.welcome;
		}
		
		public function get logoutUrl():String
		{
			return xml.logoutUrl;
		}
		
		public function get defaultLayout():String
		{
			return xml.defaultLayout;
		}
		
		public function get avatarURL():String
		{
			return xml.avatarURL;
		}
		
		public function get customdata():Object
		{
			if ( xml.customdata )
			{
				var _customdata:Object = {};
				for each ( var cdnode:XML in xml.customdata.elements() )
				{
					_customdata[ cdnode.name() ] = cdnode.toString();
				}
				return _customdata;
			}
			return {};
		}
	
	}

}