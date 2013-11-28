package cc.minos.bigbluebutton.plugins.users
{
	import cc.minos.bigbluebutton.events.BigBlueButtonEvent;
	import cc.minos.bigbluebutton.model.BBBUser;
	import cc.minos.bigbluebutton.plugins.Plugin;
	import cc.minos.bigbluebutton.Role;
	import cc.minos.console.Console;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.Timer;
	
	/**
	 * 在線用戶應用（必須）
	 * 用戶加入退出房間，語音，視頻狀態處理
	 * @author Minos
	 */
	public class UsersPlugin extends Plugin implements IUsersManager
	{
		/** 獲取在線用戶數據 */
		private static const GET_PARTICIPANTS:String = "participants.getParticipants";
		/** 設置用戶狀態 */
		private static const SET_PARTICIPANT_STATUS:String = "participants.setParticipantStatus";
		/** 設置演講者 */
		private static const SET_PRESENTER:String = "participants.assignPresenter";
		/** 獲取語音房間的用戶 */
		private const GET_MEETMEUSERS:String = "voice.getMeetMeUsers";
		/** 獲取房間的狀態 */
		private const GET_ROOMMUTED_STATE:String = "voice.isRoomMuted";
		/** 設置用戶麥克風是否禁用 */
		private const SET_LOCK_USER:String = "voice.lockMuteUser";
		/** 設置是否靜音用戶麥克風 */
		private const SET_MUTE_USER:String = "voice.muteUnmuteUser";
		/** 靜音全部用戶 */
		private const SET_MUTE_ALL_USER:String = "voice.muteAllUsers";
		/** 關閉用戶語音 */
		private const SET_KILL_USER:String = "voice.kickUSer";
		
		/** 自定義設置 */
		private var options:UsersOptions;
		/** 本人 */
		private var me:BBBUser;
		/** 狀態服務 */
		private var participantsSOService:ParticipantsSOService;
		/** 語音服務 */
		private var listenersSOService:ListenersSOService;
		/** 用戶數據 */
		public var users:Array;
		/** 刷新頻率 */
		private var refreshTimer:Timer;
		
		public function UsersPlugin( options:UsersOptions = null )
		{
			super();
			this.options = options;
			if ( this.options == null )
				this.options = new UsersOptions();
			this.name = "[UsersPlugin]";
			this.shortcut = "users";
		}
		
		/**
		 * 初始化用戶應用
		 */
		override protected function init():void
		{
			refreshTimer = new Timer( 200 );
			me = new BBBUser();
			users = [];
			participantsSOService = new ParticipantsSOService( this );
			listenersSOService = new ListenersSOService( this );
		}
		
		/**
		 * 啟用用戶應用
		 * 連接服務
		 */
		override public function start():void
		{
			participantsSOService.connect( connection, uri );
			listenersSOService.connect( connection, uri );
			refreshTimer.addEventListener( TimerEvent.TIMER, onRefreshTimer );
			
			getParticipants();
			getMeetMeUsers();
			getRoomMuteState();
		}
		
		/**
		 * 停止用戶應用
		 */
		override public function stop():void
		{
			me = null;
			users.length = 0;
			participantsSOService.disconnect();
			listenersSOService.disconnect();
			refreshTimer.removeEventListener( TimerEvent.TIMER, onRefreshTimer );
		}
		
		/**
		 * 服務器地址
		 */
		override public function get uri():String
		{
			var _uri:String = super.uri + "/" + bbb.conferenceParameters.room;
			return _uri;
		}
		
		/*********************************************** (用戶狀態接口) ***********************************************************/
		
		/** 
		 * 獲取當前在線用戶
		 */
		private function getParticipants():void
		{
			bbb.send([ GET_PARTICIPANTS, new Responder( onGetParticipantsResult, onGetParticipantsStatus ) ] );
		}
		
		private function onGetParticipantsResult( result:Object ):void
		{
			//Console.log( "在線人數: " + result.count );
			if ( result.count > 0 )
			{
				for ( var p:Object in result.participants )
				{
					participantsSOService.participantJoined( result.participants[ p ] );
				}
			}
			becomePresenterIfLoneModerator();
		}
		
		private function becomePresenterIfLoneModerator():void
		{
			if ( hasOnlyOneModerator() )
			{
				var user:BBBUser = getTheOnlyModerator();
				if ( user )
				{
					assignPresenter( user.userID, user.name, 1 );
				}
			}
		}
		
		private function onGetParticipantsStatus( status:Object ):void
		{
			dispatchRawEvent( new BigBlueButtonEvent( BigBlueButtonEvent.UNKNOWN_REASON ) );
		}
		
		/**
		 * 添加視頻流
		 * @param	userID		:	用戶ID
		 * @param	streamName	:	視頻流名稱
		 */
		public function addStream( userID:String, streamName:String ):void
		{
			bbb.send([ SET_PARTICIPANT_STATUS, responder, userID, "hasStream", "true,stream=" + streamName ] );
		}
		
		/**
		 * 移除視頻流
		 * @param	userID		:	用戶ID
		 * @param	streamName	:	視頻流名稱
		 */
		public function removeStream( userID:String, streamName:String ):void
		{
			bbb.send([ SET_PARTICIPANT_STATUS, responder, userID, "hasStream", "false,stream=" + streamName ] );
		}
		
		/**
		 * 設置演講者
		 * @param	userID		:	用戶ID
		 * @param	name		:	用戶名
		 * @param	assignedBy	:
		 */
		public function assignPresenter( userID:String, name:String, assignedBy:Number ):void
		{
			bbb.send([ SET_PRESENTER, responder, userID, name, assignedBy ] );
		}
		
		/**
		 * 舉手
		 * @param	userID		:	用戶ID
		 * @param	raise		:	是否舉手(true|false)
		 */
		public function raiseHand( userID:String, raise:Boolean ):void
		{
			bbb.send([ SET_PARTICIPANT_STATUS, responder, userID, "raiseHand", raise ] );
		}
		
		public function raiseMyHand( raise:Boolean ):void
		{
			bbb.send( [ SET_PARTICIPANT_STATUS, responder, me.userID, "raiseHand", raise ] );
		}
		
		/**
		 * 踢人
		 * @param	userID		:	用戶ID
		 */
		public function kickUser( userID:String ):void
		{
			if ( options.allowKickUser ) {
				participantsSOService.kickUser( userID );
			}
			else
			{
				
			}
		}
		
		/******************************************** (用戶語音狀態接口) ********************************************************/
		
		/**
		 * 獲取當前加入語音列表的用戶
		 */
		private function getMeetMeUsers():void
		{
			bbb.send([ GET_MEETMEUSERS, new Responder( onGetMeetMeUsersResult ) ] );
		}
		
		private function onGetMeetMeUsersResult( result:Object ):void
		{
			if ( result.count > 0 )
			{
				for ( var p:Object in result.participants )
				{
					var u:Object = result.participants[ p ];
					listenersSOService.userJoin( u.participant, u.name, u.name, u.muted, u.talking, u.locked );
				}
			}
		}
		
		/**
		 *
		 */
		public function getRoomMuteState():void
		{
			bbb.send([ GET_ROOMMUTED_STATE, new Responder( function( result:Object ):void
				{
					listenersSOService.muteStateCallback( result as Boolean );
				} ) ] );
		}
		
		/**
		 * 踢出語音用戶
		 * @param	userID
		 */
		public function ejectUser( userID:Number ):void
		{
			bbb.send([ SET_KILL_USER, responder, userID ] );
		}
		
		/**
		 * 靜音所有用戶
		 * @param	mute
		 */
		public function muteAllUsers( mute:Boolean ):void
		{
			bbb.send([ SET_MUTE_ALL_USER, responder, mute ] );
			listenersSOService.muteAllUsers( mute );
		}
		
		/**
		 * 設置用戶靜音狀態
		 * @param	userID
		 * @param	mute
		 */
		public function muteUnmuteUser( userID:Number, mute:Boolean ):void
		{
			bbb.send([ SET_MUTE_USER, responder, userID, mute ] );
		}
		
		/**
		 * 設置用戶麥克風鎖定狀態
		 * @param	userID
		 * @param	lock
		 */
		public function lockMuteUser( userID:Number, lock:Boolean ):void
		{
			bbb.send([ SET_LOCK_USER, responder, userID, lock ] );
		}
		
		/** cc.minos.bigbluebutton.plugins.users.IUsersManager (用戶管理接口) */
		
		/**
		 * 添加用戶到數組
		 * @param	newuser
		 */
		public function addUser( newuser:BBBUser ):void
		{
			if ( !hasUser( newuser.userID ) )
			{
				if ( newuser.userID == userID )
				{
					newuser.externUserID = bbb.conferenceParameters.externUserID;
					newuser.me = true;
					me = newuser;
				}
				users.push( newuser );
				refresh();
			}
		}
		
		/**
		 * 移除用戶
		 * @param	userID
		 * @return
		 */
		public function hasUser( userID:String ):Boolean
		{
			var p:Object = getUserIndex( userID );
			if ( p != null )
			{
				return true;
			}
			return false;
		}
		
		/**
		 * 判斷是否只有一個管理員
		 * @return 只有一個管理員返回true，默認false
		 */
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
		
		/**
		 * 獲取唯一的管理員
		 * @return	如果有則返回BBBUser，沒返回null
		 */
		public function getTheOnlyModerator():BBBUser
		{
			if ( !hasOnlyOneModerator() )
				return null;
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
		
		/**
		 * 獲取演講者
		 * @return	如果有則返回BBBUser，沒返回null
		 */
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
		
		/**
		 * 獲取用戶
		 * @param	userID	:	用戶ID
		 * @return	如果有則返回BBBUser，沒返回null
		 */
		public function getUser( userID:String ):BBBUser
		{
			var p:Object = getUserIndex( userID );
			if ( p != null )
			{
				return p.participant as BBBUser;
			}
			
			return null;
		}
		
		/**
		 * 判斷用戶是否演講者
		 * @param	userID		:	用戶ID
		 * @return	用戶如果為演講者則返回true，不然返回false
		 */
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
		
		/**
		 * 移除用戶
		 * @param	userID		:	用戶ID
		 */
		public function removeUser( userID:String ):void
		{
			var p:Object = getUserIndex( userID );
			if ( p != null )
			{
				users.splice( p.index, 1 );
				refresh();
			}
		}
		
		/**
		 * 獲取用戶{}
		 * @param	userID
		 * @return
		 */
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
		
		/**
		 * 根據語音id獲取用戶
		 * @param	voiceUserID
		 * @return	如果有則返回BBBUser，沒返回null
		 */
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
		
		/**
		 * @return
		 */
		public function getMe():BBBUser
		{
			return me;
		}
		
		/**
		 *
		   public function removeAllParticipants():void
		   {
		   users.length = 0;
		   refresh();
		 }*/
		
		/**
		 * 獲取用戶id數組
		 * @return
		 */
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
		
		/**
		 *
		 * @param	e
		 */
		private function onRefreshTimer( e:TimerEvent ):void
		{
			users.sort( sortFunction );
			dispatchEvent( new UsersEvent( UsersEvent.REFRESH ) );
			refreshTimer.stop();
		}
		
		/**
		 * 刷新用戶
		 */
		public function refresh():void
		{
			if ( !refreshTimer.running )
				refreshTimer.start();
		}
		
		/**
		 * 房間名
		 */
		public function get room():String
		{
			return bbb.conferenceParameters.room;
		}
		
		/**
		 * 根據用戶狀態、權限排序
		 * @param	a
		 * @param	b
		 * @param	array
		 * @return
		 */
		private function sortFunction( a:Object, b:Object, array:Array = null ):int
		{
			if ( a.presenter )
			{
				return -1;
			}
			else if ( b.presenter )
			{
				return 1;
			}
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
			/*else if ( a.phoneUser && b.phoneUser )
			   {
			   }
			   else if ( a.phoneUser )
			   return -1;
			   else if ( b.phoneUser )
			 return 1;*/
			
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