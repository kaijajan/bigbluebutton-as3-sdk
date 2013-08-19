package cc.minos.bbb
{
	import cc.minos.bbb.events.StreamStartedEvent;
	import cc.minos.event.EventProxy;
	
	//import cc.minos.talk3.proxy.events.StreamStartedEvent;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class BBBUser
	{
		public static const MODERATOR:String = "MODERATOR";
		public static const VIEWER:String = "VIEWER";
		public static const PRESENTER:String = "PRESENTER";
		
		public var userID:String = "UNKNOWN USER";
		public var externUserID:String = "UNKNOWN USER";
		public var name:String;
		
		public var me:Boolean = false;
		public var talking:Boolean = false;
		public var phoneUser:Boolean = false;
		
		private var _hasStream:Boolean = false;
		private var _presenter:Boolean = false;
		private var _raiseHand:Boolean = false;
		private var _role:String = VIEWER;
		private var _userStatus:String = "";
		
		public var viewingStream:Boolean = false;
		public var streamName:String = "";
		public var isLeavingFlag:Boolean = false;
		
		public var room:String = "";
		public var authToken:String = "";
		public var selected:Boolean = false;
		public var voiceUserid:Number = 0;
		
		public var customdata:Object = {};
		
		public function BBBUser()
		{
		}
		
		public function get hasStream():Boolean
		{
			return _hasStream;
		}
		
		public function set hasStream( s:Boolean ):void
		{
			_hasStream = s;
			verifyMedia();
		}
		
		public function get presenter():Boolean
		{
			return _presenter;
		}
		
		public function set presenter( p:Boolean ):void
		{
			_presenter = p;
			verifyUserStatus();
		}
		
		public function get raiseHand():Boolean
		{
			return _raiseHand;
		}
		
		public function set raiseHand( r:Boolean ):void
		{
			_raiseHand = r;
			verifyUserStatus();
		}
		
		public function get role():String
		{
			return _role;
		}
		
		public function set role( r:String ):void
		{
			_role = r;
			verifyUserStatus();
		}
		
		public function get userStatus():String
		{
			return _userStatus;
		}
		
		public function set userStatus( value:String ):void
		{
			_userStatus = value;
		}
		
		private function verifyUserStatus():void
		{
			if ( presenter )
				_userStatus = 'presenter';
			else if ( role == MODERATOR )
				_userStatus = 'moderator';
			else if ( raiseHand )
				_userStatus = 'handRaised';
			else
				_userStatus = 'viewer';
		}
		
		private var _media:String = "";
		
		public function get media():String
		{
			return _media;
		}
		
		public function set media( m:String ):void
		{
		}
		
		private function verifyMedia():void
		{
			_media = ( hasStream ? "webcam" + " " : "" ) + ( !voiceJoined ? "noAudio" : ( voiceMuted ? "micOff" : "micOn" ) );
		}
		
		private var _voiceJoined:Boolean = false;
		
		public function get voiceJoined():Boolean
		{
			return _voiceJoined;
		}
		
		public function set voiceJoined( v:Boolean ):void
		{
			_voiceJoined = v;
			buildStatus();
		}
		
		private var _voiceMuted:Boolean = false;
		
		public function get voiceMuted():Boolean
		{
			return _voiceMuted;
		}
		
		public function set voiceMuted( v:Boolean ):void
		{
			_voiceMuted = v;
			verifyMedia();
		}
		
		public var voiceLocked:Boolean = false;
		public var status:String = "";
		
		public function buildStatus():void
		{
			var showingWebcam:String = "";
			//var isPresenter:String = "";
			var showingMic:String = "";
			var handRaised:String = "";
			if ( hasStream )
				showingWebcam = "streamIcon";
			//if ( presenter )
			//isPresenter = "presIcon";
			if ( voiceJoined )
				showingMic = "audioIcon";
			if ( raiseHand )
				handRaised = "raiseHand";
			
			status = showingWebcam + showingMic + handRaised;
		
		}
		
		public function changeStatus( status:Status ):void
		{
			//_status.changeStatus(status);
			/*if ( status.name == "presenter" )
			   {
			   presenter = status.value
			 }*/
			switch ( status.name )
			{
				case "presenter": 
					presenter = status.value;
					break;
				case "hasStream": 
					var streamInfo:Array = String( status.value ).split( /,/ );
					/**
					 * Cannot use this statement as new Boolean(expression)
					 * return true if the expression is a non-empty string not
					 * when the string equals "true". See Boolean class def.
					 *
					 * hasStream = new Boolean(String(streamInfo[0]));
					 */
					if ( String( streamInfo[ 0 ] ).toUpperCase() == "TRUE" )
					{
						hasStream = true;
					}
					else
					{
						hasStream = false;
					}
					
					var streamNameInfo:Array = String( streamInfo[ 1 ] ).split( /=/ );
					streamName = streamNameInfo[ 1 ];
					if ( hasStream )
						sendStreamStartedEvent();
					break;
				case "raiseHand": 
					raiseHand = status.value as Boolean;
					if ( me )
					{
						//TALK3.initUserManager().isMyHandRaised = status.value;
					}
					break;
			}
			buildStatus();
		}
		
		public function toString():String
		{
			return name
		}
		
		private function sendStreamStartedEvent():void
		{
			EventProxy.broadcastEvent( new StreamStartedEvent( userID, name, streamName ) );
		}
		
		public static function copy( user:BBBUser ):BBBUser
		{
			var n:BBBUser = new BBBUser();
			n.authToken = user.authToken;
			n.me = user.me;
			n.userID = user.userID;
			n.name = user.name;
			n.externUserID = user.externUserID;
			n.hasStream = user.hasStream;
			n.streamName = user.streamName;
			n.presenter = user.presenter;
			n.raiseHand = user.raiseHand;
			n.role = user.role;
			n.room = user.room;
			
			return n;
		}
	}

}