
package cc.minos.bbb.plugins.users
{
	import cc.minos.bbb.BBBUser;
	import cc.minos.bbb.plugins.Plugin;
	import cc.minos.bbb.plugins.users.UsersOptions;
	import cc.minos.bbb.Status;
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
		
		public var users:Vector.<BBBUser>;
		
		public function UsersPlugin( options:UsersOptions = null )
		{
			super();
			this.options = options;
			this.name = "[UsersPlugin]";
			this.shortcut = "users";
		}
		
		override public function init():void
		{
			me = new BBBUser();
			users = new Vector.<BBBUser>();
			
			participantsSOService = new ParticipantsSOService( this );
			participantsSOService.addEventListener( PariticipantEvent.JOINED, onPariticipant );
			participantsSOService.addEventListener( PariticipantEvent.KICKED, onPariticipant );
			participantsSOService.addEventListener( PariticipantEvent.LEFT, onPariticipant );
			
			listenersSOService = new ListenersSOService( this );
		}
		
		private function onPariticipant( e:PariticipantEvent ):void
		{
			dispatchEvent( e );
		}
		
		override public function start():void
		{
			participantsSOService.connect();
			listenersSOService.connect();
		}
		
		public function addUser( newuser:BBBUser ):void
		{
			if ( !hasUser( newuser.userID ) )
			{
				//trace( "adding user[" + newuser.name + "," + newuser.userID + "]" );
				if ( newuser.userID == me.userID )
					newuser.me = true;
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
				if ( p.role == BBBUser.MODERATOR )
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
				if ( p.role == BBBUser.MODERATOR )
				{
					return BBBUser.copy( p );
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
					return BBBUser.copy( p );
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
		
		public function getUserWithExternUserID( userID:String ):BBBUser
		{
			var p:BBBUser;
			for ( var i:int = 0; i < users.length; i++ )
			{
				p = users[ i ];
				if ( p.externUserID == userID )
				{
					return BBBUser.copy( p );
				}
			}
			
			return null;
		}
		
		public function isUserPresenter( userID:String ):Boolean
		{
			var user:Object = getUserIndex( userID );
			if ( user == null )
			{
				//trace( "User not found with id=" + userID );
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
				//trace( "removing user[" + p.participant.name + "," + p.participant.userID + "]" );
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
		
		private function refresh():void
		{
			users.sort( sortFunction );
			dispatchEvent( new PariticipantEvent( PariticipantEvent.REFRESH ) );
		}
		
		public function get room():String
		{
			return bbb.conferenceParameters.room;
		}
		
		public function get connection():NetConnection
		{
			return bbb.conferenceParameters.connection;
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
			if ( a.presenter )
				return -1;
			else if ( b.presenter )
				return 1;
			if ( a.role == BBBUser.MODERATOR && b.role == BBBUser.MODERATOR )
			{
				// do nothing go to the end and check names
			}
			else if ( a.role == BBBUser.MODERATOR )
				return -1;
			else if ( b.role == BBBUser.MODERATOR )
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