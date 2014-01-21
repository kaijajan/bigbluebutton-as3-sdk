package cc.minos.bigbluebutton.plugins.users
{
	import cc.minos.bigbluebutton.events.MadePresenterEvent;
	import cc.minos.bigbluebutton.events.UsersEvent;
	import cc.minos.bigbluebutton.models.BBBUser;
	import cc.minos.bigbluebutton.models.IUsersList;
	import cc.minos.bigbluebutton.models.UsersList;
	import cc.minos.bigbluebutton.plugins.Plugin;
	import flash.net.Responder;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class UsersPlugin extends Plugin implements IParticipantsSOServiceClient, IListenersSOServiceClient, IUsersPlugin
	{
		protected const GET_PARTICIPANTS:String = "participants.getParticipants";
		protected const SET_PARTICIPANT_STATUS:String = "participants.setParticipantStatus";
		protected const SET_PRESENTER:String = "participants.assignPresenter";
		protected const GET_MEETMEUSERS:String = "voice.getMeetMeUsers";
		protected const GET_ROOM_STATUS:String = "voice.isRoomMuted";
		protected const SET_LOCK_USER:String = "voice.lockMuteUser";
		protected const SET_MUTE_USER:String = "voice.muteUnmuteUser";
		protected const SET_MUTE_ALL_USER:String = "voice.muteAllUsers";
		protected const SET_KILL_USER:String = "voice.kickUSer";
		
		protected var _usersList:IUsersList;
		protected var options:UsersOptions;
		
		protected var participantsSO:ParticipantsSOService;
		protected var listenersSO:ListenersSOService;
		
		public function UsersPlugin( options:UsersOptions = null )
		{
			super();
			if ( options == null )
				options = new UsersOptions();
			this.options = options;
			this._name = "[UsersPlugin]";
			this._shortcut = "users";
		}
		
		/**
		 *
		 */
		override public function start():void
		{
			participantsSO.connect( connection, uri );
			listenersSO.connect( connection, uri );
			
			bbb.send( GET_PARTICIPANTS, new Responder( onGetParticipantsResult ) );
			bbb.send( GET_MEETMEUSERS, new Responder( onGetMeetMeUsersResult ) );
			bbb.send( GET_ROOM_STATUS, new Responder( muteStateCallback ) );
		}
		
		/**
		 *
		 */
		override public function stop():void
		{
			participantsSO.disconnect();
			listenersSO.disconnect();
		}
		
		/**
		 *
		 */
		override public function get uri():String
		{
			return super.uri + "/" + bbb.conferenceParameters.room;
		}
		
		override public function init():void
		{
			_usersList = new UsersList();
			
			participantsSO = new ParticipantsSOService( this );
			listenersSO = new ListenersSOService( this );
		
		}
		
		protected function onGetParticipantsResult( result:Object ):void
		{
			if ( result.count > 0 )
			{
				trace( name + " online: " + result.count );
				for ( var p:Object in result.participants )
				{
					participantJoined( result.participants[ p ] );
				}
			}
			if ( options.autoPresenter && usersList.hasOnlyOneModerator() )
			{
				var user:BBBUser = usersList.getTheOnlyModerator();
				if ( user )
				{
					trace( name + " assign presenter > " + user.userID );
					assignPresenter( user.userID, user.name, 1 );
				}
			}
		}
		
		protected function onGetMeetMeUsersResult( result:Object ):void
		{
			if ( result.count > 0 )
			{
				trace( name + " voice: " + result.count );
				for ( var p:Object in result.participants )
				{
					var u:Object = result.participants[ p ];
					userJoin( u.participant, u.name, u.name, u.muted, u.talking, u.locked );
				}
			}
		}
		
		public function participantJoined( joinedUser:Object ):void
		{
			var user:BBBUser = new BBBUser();
			user.userID = joinedUser.userid;
			user.name = joinedUser.name;
			user.role = joinedUser.role;
			user.externUserID = joinedUser.externUserID;
			user.isLeavingFlag = false;
			
			if ( user.userID == userID )
			{
				user.me = true;
				usersList.me = user;
			}
			usersList.addUser( user );
			
			sendUsersEvent( UsersEvent.JOINED, user.userID );
			
			participantStatusChange( user.userID, "hasStream", joinedUser.status.hasStream );
			participantStatusChange( user.userID, "presenter", joinedUser.status.presenter );
			participantStatusChange( user.userID, "raiseHand", joinedUser.status.raiseHand );
		}
		
		public function participantLeft( userID:String ):void
		{
			var user:BBBUser = usersList.getUser( userID );
			if ( user != null )
			{
				user.isLeavingFlag = true;
				usersList.removeUser( userID );
				sendUsersEvent( UsersEvent.LEFT, user.userID );
			}
		}
		
		public function assignPresenter( userID:String, name:String, assignedBy:Number ):void
		{
			bbb.send( SET_PRESENTER, null, userID, name, assignedBy );
		}
		
		public function assignPresenterCallback( userID:String, name:String, assignedBy:String ):void
		{
			var pEvent:MadePresenterEvent;
			
			if ( this.userID == userID )
			{
				trace( this.name + " " + name + " switch to presenter" );
				pEvent = new MadePresenterEvent( MadePresenterEvent.SWITCH_TO_PRESENTER_MODE );
			}
			else
			{
				trace( this.name + " " + name + " switch to viewer" );
				pEvent = new MadePresenterEvent( MadePresenterEvent.SWITCH_TO_VIEWER_MODE );
			}
			pEvent.userID = userID;
			pEvent.assignerBy = assignedBy;
			pEvent.presenterName = name;
			dispatchRawEvent( pEvent );
		}
		
		public function kickUser( userID:String ):void
		{
			if ( options.allowKickUser )
			{
				participantsSO.kickUser( userID );
			}
		}
		
		public function kickUserCallback( userID:String ):void
		{
			sendUsersEvent( UsersEvent.KICKED, userID );
		}
		
		public function participantStatusChange( userID:String, status:String, value:Object ):void
		{
			var user:BBBUser = usersList.getUser( userID );
			if ( user != null )
			{
				trace( name + " status change: " + userID + "." + status + "=" + value );
				switch ( status )
				{
					case "presenter": 
						user.presenter = value as Boolean;
						dispatchRawEvent( new MadePresenterEvent( MadePresenterEvent.PRESENTER_NAME_CHANGE ) );
						break;
					case "hasStream": 
						var streamInfo:Array = String( value ).split( /,/ );
						user.hasStream = ( String( streamInfo[ 0 ] ).toUpperCase() == "TRUE" );
						var streamNameInfo:Array = String( streamInfo[ 1 ] ).split( /=/ );
						user.streamName = streamNameInfo[ 1 ];
						if ( user.hasStream )
						{
							sendUsersEvent( UsersEvent.USER_VIDEO_STREAM_STARTED, user.userID );
						}
						else
						{
							if ( user.streamName != null )
							{
								user.streamName = null;
								sendUsersEvent( UsersEvent.USER_VIDEO_STREAM_STOPED, user.userID );
							}
						}
						break;
					case "raiseHand": 
						user.raiseHand = value as Boolean;
						sendUsersEvent( UsersEvent.RAISE_HAND, user.userID );
						break;
				}
			}
		
		}
		
		public function muteStateCallback( mute:Boolean ):void
		{
		}
		
		public function userLeft( voiceID:Number ):void
		{
			var user:BBBUser = usersList.getUserByVoiceID( voiceID );
			if ( user )
			{
				user.voiceJoined = false;
				user.voiceUserID = 0;
				user.talking = false
				user.voiceMuted = false;
				user.voiceLocked = false;
				sendUsersEvent( UsersEvent.USER_VOICE_LEFT, user.userID );
			}
		}
		
		public function userTalk( voiceID:Number, talk:Boolean ):void
		{
			var user:BBBUser = usersList.getUserByVoiceID( voiceID );
			if ( user )
			{
				user.talking = talk;
				sendUsersEvent( UsersEvent.USER_VOICE_TALKING, user.userID );
			}
		}
		
		public function userLockedMute( voiceID:Number, locked:Boolean ):void
		{
			var user:BBBUser = usersList.getUserByVoiceID( voiceID );
			if ( user )
			{
				user.voiceLocked = locked;
				sendUsersEvent( UsersEvent.USER_VOICE_LOCKED, user.userID );
			}
		}
		
		public function userMute( voiceID:Number, mute:Boolean ):void
		{
			var user:BBBUser = usersList.getUserByVoiceID( voiceID );
			if ( user )
			{
				user.voiceMuted = mute;
				sendUsersEvent( UsersEvent.USER_VOICE_MUTED, user.userID );
				if ( user.voiceMuted )
				{
					userTalk( voiceID, false );
				}
			}
		}
		
		public function userJoin( voiceID:Number, cidName:String, cidNum:String, muted:Boolean, talking:Boolean, locked:Boolean ):void
		{
			if ( cidName )
			{
				var pattern:RegExp = /(.*)-bbbID-(.*)$/;
				var result:Object = pattern.exec( cidName );
				
				if ( result != null )
				{
					if ( usersList.hasUser( result[ 1 ] ) )
					{
						trace( name + " voice join: " + cidName );
						var user:BBBUser = usersList.getUser( result[ 1 ] );
						user.voiceUserID = voiceID;
						user.voiceMuted = muted;
						user.voiceJoined = true;
						user.talking = talking;
						user.voiceLocked = locked;
						sendUsersEvent( UsersEvent.USER_VOICE_JOINED, user.userID );
					}
				}
			}
		}
		
		private var pingCount:int = 0;
		
		public function ping( message:String ):void
		{
			if ( pingCount < 100 )
			{
				pingCount++;
			}
			else
			{
				var date:Date = new Date();
				var t:String = date.toLocaleTimeString();
				trace( "[" + t + '] - Received ping from server: ' + message );
				pingCount = 0;
			}
		}
		
		protected function sendUsersEvent( type:String, userID:String ):void
		{
			var usersEvent:UsersEvent = new UsersEvent( type );
			usersEvent.userID = userID;
			dispatchRawEvent( usersEvent );
		}
		
		/* INTERFACE cc.minos.bigbluebutton.plugins.users.IUsersPlugin */
		
		public function raiseHand( userID:String, raise:Boolean ):void
		{
			bbb.send( SET_PARTICIPANT_STATUS, null, userID, "raiseHand", raise );
		}
		
		public function ejectVoiceUser( voiceID:Number ):void
		{
			bbb.send( SET_KILL_USER , null, voiceID );
		}
		
		public function muteAllUsers( mute:Boolean ):void
		{
			bbb.send( SET_MUTE_ALL_USER, null, mute );
		}
		
		public function muteUser( voiceID:Number, mute:Boolean ):void
		{
			bbb.send( SET_MUTE_USER, null, voiceID, mute );
		}
		
		public function lockUser( voiceID:Number, lock:Boolean ):void
		{
			bbb.send( SET_LOCK_USER, null, voiceID, lock );
		}
		
		public function addStream( userID:String, streamName:String ):void
		{
			bbb.send( SET_PARTICIPANT_STATUS, null, userID, "hasStream", "true,stream=" + streamName );
		}
		
		public function removeStream( userID:String, streamName:String ):void
		{
			bbb.send( SET_PARTICIPANT_STATUS, null, userID, "hasStream", "false,stream=" + streamName );
		}
		
		public function get usersList():IUsersList 
		{
			return _usersList;
		}
	}
}