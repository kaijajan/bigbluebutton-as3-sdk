
package cc.minos.bigbluebutton.plugins
{
	import cc.minos.bigbluebutton.model.BBBUser;
	import cc.minos.bigbluebutton.model.Status;
	import cc.minos.bigbluebutton.plugins.users.*;
	import cc.minos.bigbluebutton.Role;
	import flash.net.NetConnection;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class UsersPlugin extends Plugin
	{
		
		private var options:UsersOptions;
		private var me:BBBUser;
		
		private var participantsSOService:ParticipantsSOService;
		private var listenersSOService:ListenersSOService;
		
		public var users:Array;
		
		public function UsersPlugin( options:UsersOptions = null )
		{
			super();
			this.options = options;
			if ( this.options == null )
				this.options = new UsersOptions();
			this.name = "[UsersPlugin]";
			this.shortcut = "users";
		}
		
		override public function init():void
		{
			me = new BBBUser();
			users = [];
			participantsSOService = new ParticipantsSOService( this );
			listenersSOService = new ListenersSOService( this );
		}
		
		override public function start():void
		{
			participantsSOService.connect();
			listenersSOService.connect();
		}
		
		override public function stop():void
		{
			me = null;
			users.length = 0;
			participantsSOService.disconnect();
			listenersSOService.disconnect();
		}
		
		override public function get uri():String
		{
			var _uri:String = super.uri + "/" + bbb.conferenceParameters.room;
			return _uri;
		}
		
		// ---------------------------------  status --------------------------------- //
		
		public function addStream( userID:String, streamName:String ):void
		{
			participantsSOService.addStream( userID, streamName );
		}
		
		public function removeStream( userID:String, streamName:String ):void
		{
			participantsSOService.removeStream( userID, streamName );
		}
		
		public function assignPresenter( userid:String, name:String, assignedBy:Number ):void
		{
			participantsSOService.assignPresenter( userid, name, assignedBy );
		}
		
		public function raiseHand( userID:String, raise:Boolean ):void
		{
			participantsSOService.raiseHand( userID, raise );
		}
		
		
		//  ---------------------------------    users manager    ----------------------------------  //
		
		public function addUser( newuser:BBBUser ):void
		{
			if ( !hasUser( newuser.userID ) )
			{
				if ( newuser.userID == bbb.conferenceParameters.userID )
				{
					newuser.externUserID = bbb.conferenceParameters.externUserID;
					newuser.me = true;
					me = newuser;
				}
				users.push( newuser );
				refresh();
			}
		}
		
		public function hasUser( userID:String ):Boolean
		{
			var p:Object = getUserIndex( userID );
			if ( p != null )
			{
				return true;
			}
			return false;
		}
		
		public function hasOnlyOneModerator():Boolean
		{
			var p:BBBUser;
			var moderatorCount:int = 0;
			for ( var i:int = 0; i < users.length; i++ )
			{
				p = users[ i ];
				if ( p.role == Role.MODERATOR )
				{
					moderatorCount++;
				}
			}
			if ( moderatorCount == 1 )
				return true;
			return false;
		}
		
		public function getTheOnlyModerator():BBBUser
		{
			var p:BBBUser;
			for ( var i:int = 0; i < users.length; i++ )
			{
				p = users[ i ];
				if ( p.role == Role.MODERATOR )
				{
					return p;
				}
			}
			return null;
		}
		
		public function getPresenter():BBBUser
		{
			var p:BBBUser;
			for ( var i:int = 0; i < users.length; i++ )
			{
				p = users[ i ];
				if ( isUserPresenter( p.userID ) )
				{
					return p;
				}
			}
			
			return null;
		}
		
		public function getUser( userID:String ):BBBUser
		{
			var p:Object = getUserIndex( userID );
			if ( p != null )
			{
				return p.participant as BBBUser;
			}
			
			return null;
		}
		
		public function isUserPresenter( userID:String ):Boolean
		{
			var user:Object = getUserIndex( userID );
			if ( user == null )
			{
				return false;
			}
			var a:BBBUser = user.participant as BBBUser;
			return a.presenter;
		}
		
		public function removeUser( userID:String ):void
		{
			var p:Object = getUserIndex( userID );
			if ( p != null )
			{
				users.splice( p.index, 1 );
				refresh();
			}
		}
		
		private function getUserIndex( userID:String ):Object
		{
			var aUser:BBBUser;
			
			for ( var i:int = 0; i < users.length; i++ )
			{
				aUser = users[ i ];
				if ( aUser.userID == userID )
				{
					return { index: i, participant: aUser };
				}
			}
			return null;
		}
		
		public function getVoiceUser( voiceUserID:Number ):BBBUser
		{
			for ( var i:int = 0; i < users.length; i++ )
			{
				var aUser:BBBUser = users[ i ];
				if ( aUser.voiceUserid == voiceUserID )
					return aUser;
			}
			
			return null;
		}
		
		public function getMe():BBBUser
		{
			return me;
		}
		
		public function removeAllParticipants():void
		{
			users.length = 0;
		}
		
		public function newUserStatus( userID:String, status:String, value:Object ):void
		{
			var aUser:BBBUser = getUser( userID );
			trace( "newUserStatus", userID );
			if ( aUser != null )
			{
				var s:Status = new Status( status, value );
				aUser.changeStatus( s );
			}
			refresh();
		}
		
		public function getUserIDs():Array
		{
			var uids:Array = new Array();
			for ( var i:int = 0; i < users.length; i++ )
			{
				var u:BBBUser = users[ i ];
				uids.push( u.userID );
			}
			return uids;
		}
		
		public function getUsers():Array
		{
			var us:Array = [];
			for ( var i:int = 0; i < users.length; i++ )
			{
				us.push( users[ i ] );
			}
			return us;
		}
		
		private function refresh():void
		{
			users.sort( sortFunction );
			dispatchEvent( new UsersEvent( UsersEvent.REFRESH ) );
		}
		
		public function get room():String
		{
			return bbb.conferenceParameters.room;
		}
		
		/**
		 * 排序
		 * @param	a
		 * @param	b
		 * @param	array
		 * @return
		 */
		private function sortFunction( a:Object, b:Object, array:Array = null ):int
		{
			/*if ( a.presenter )
			   return -1;
			   else if ( b.presenter )
			 return 1;*/
			if ( a.role == Role.MODERATOR && b.role == Role.MODERATOR )
			{
				// do nothing go to the end and check names
			}
			else if ( a.role == Role.MODERATOR )
				return -1;
			else if ( b.role == Role.MODERATOR )
				return 1;
			else if ( a.raiseHand && b.raiseHand )
			{
				// do nothing go to the end and check names
			}
			else if ( a.raiseHand )
				return -1;
			else if ( b.raiseHand )
				return 1;
			else if ( a.phoneUser && b.phoneUser )
			{
				
			}
			else if ( a.phoneUser )
				return -1;
			else if ( b.phoneUser )
				return 1;
			
			/*
			 * Check name (case-insensitive) in the event of a tie up above. If the name
			 * is the same then use userID which should be unique making the order the same
			 * across all clients.
			 */
			if ( a.name.toLowerCase() < b.name.toLowerCase() )
				return -1;
			else if ( a.name.toLowerCase() > b.name.toLowerCase() )
				return 1;
			else if ( a.userID.toLowerCase() > b.userID.toLowerCase() )
				return -1;
			else if ( a.userID.toLowerCase() < b.userID.toLowerCase() )
				return 1;
			
			return 0;
		}
	
	}
}