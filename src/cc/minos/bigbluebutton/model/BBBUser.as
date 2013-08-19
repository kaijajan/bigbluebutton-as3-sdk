package cc.minos.bigbluebutton.model
{
	import cc.minos.bigbluebutton.Role;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class BBBUser
	{
		public var userID:String = "UNKNOWN USER";
		public var externUserID:String = "UNKNOWN USER";
		public var name:String;
		
		public var me:Boolean = false;
		public var talking:Boolean = false;
		private var _hasStream:Boolean = false;
		private var _presenter:Boolean = false;
		private var _raiseHand:Boolean = false;
		private var _role:String = Role.VIEWER;
		private var _userStatus:String = "";
		
		public var streamName:String = "";
		public var isLeavingFlag:Boolean = false;
		public var room:String = "";
		public var authToken:String = "";
		public var selected:Boolean = false;
		public var voiceUserid:Number = 0;
		
		private var _voiceJoined:Boolean = false;
		private var _voiceMuted:Boolean = false;
		private var _voiceLocked:Boolean = false;
		public var status:String = "";
		
		public function BBBUser()
		{
		}
		
		public function toString():String
		{
			return name
		}
		
		public function get role():String
		{
			return _role;
		}
		
		public function set role( r:String ):void
		{
			_role = r;
		}
		
		public function get presenter():Boolean
		{
			return _presenter;
		}
		
		public function set presenter( p:Boolean ):void
		{
			_presenter = p;
		}
		
		public function changeStatus( status:Status ):void
		{
			switch ( status.name )
			{
				case "presenter": 
					presenter = status.value;
					break;
				case "hasStream": 
					var streamInfo:Array = String( status.value ).split( /,/ );
					hasStream = ( String( streamInfo[ 0 ] ).toUpperCase() == "TRUE" );
					var streamNameInfo:Array = String( streamInfo[ 1 ] ).split( /=/ );
					streamName = streamNameInfo[ 1 ];
					break;
				case "raiseHand": 
					raiseHand = status.value as Boolean;
					break;
			}
			buildStatus();
		}
		
		public function buildStatus():void
		{
			status = "";
			if ( hasStream )
				status += "video";
			if ( voiceJoined )
				status += "voice";
			if ( voiceMuted )
				status += "muted";
			if ( voiceLocked )
				status += "locked";
			if ( raiseHand )
				status += "hand";
		}
		
		public function get voiceJoined():Boolean
		{
			return _voiceJoined;
		}
		
		public function set voiceJoined( v:Boolean ):void
		{
			_voiceJoined = v;
			buildStatus();
		}
		
		public function get raiseHand():Boolean
		{
			return _raiseHand;
		}
		
		public function set raiseHand( r:Boolean ):void
		{
			_raiseHand = r;
			buildStatus();
		}
		
		public function get hasStream():Boolean
		{
			return _hasStream;
		}
		
		public function set hasStream( s:Boolean ):void
		{
			_hasStream = s;
			buildStatus();
		}
		
		public function get voiceLocked():Boolean
		{
			return _voiceLocked;
		}
		
		public function set voiceLocked( value:Boolean ):void
		{
			_voiceLocked = value;
			buildStatus();
		}
		
		public function get voiceMuted():Boolean
		{
			return _voiceMuted;
		}
		
		public function set voiceMuted( value:Boolean ):void
		{
			_voiceMuted = value;
			buildStatus();
		}
	}

}