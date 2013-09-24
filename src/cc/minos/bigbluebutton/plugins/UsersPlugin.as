package cc.minos.bigbluebutton.plugins
{
	import cc.minos.bigbluebutton.model.BBBUser;
	import cc.minos.bigbluebutton.plugins.users.*;
	import cc.minos.bigbluebutton.Role;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.utils.Timer;
	
	/**
	 * 在線用戶應用（必須）
	 * 用戶加入退出房間，語音，視頻狀態處理
	 * @author Minos
	 */
	public class UsersPlugin extends Plugin implements IParticipants, IListeners, IUsersManager
	{
		
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
		override public function init():void
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
			participantsSOService.connect();
			listenersSOService.connect();
			refreshTimer.addEventListener( TimerEvent.TIMER, onRefreshTimer );
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
		
		/** cc.minos.bigbluebutton.plugins.users.IParticipants (用戶狀態接口) */
		
		/**
		 * 添加視頻流
		 * @param	userID		:	用戶ID
		 * @param	streamName	:	視頻流名稱
		 */
		public function addStream( userID:String, streamName:String ):void
		{
			participantsSOService.addStream( userID, streamName );
		}
		
		/**
		 * 移除視頻流
		 * @param	userID		:	用戶ID
		 * @param	streamName	:	視頻流名稱
		 */
		public function removeStream( userID:String, streamName:String ):void
		{
			participantsSOService.removeStream( userID, streamName );
		}
		
		/**
		 * 設置演講者
		 * @param	userID		:	用戶ID
		 * @param	name		:	用戶名
		 * @param	assignedBy	:
		 */
		public function assignPresenter( userID:String, name:String, assignedBy:Number ):void
		{
			participantsSOService.assignPresenter( userID, name, assignedBy );
		}
		
		/**
		 * 舉手
		 * @param	userID		:	用戶ID
		 * @param	raise		:	是否舉手(true|false)
		 */
		public function raiseHand( userID:String, raise:Boolean ):void
		{
			participantsSOService.raiseHand( userID, raise );
		}
		
		/**
		 * 踢人
		 * @param	userID		:	用戶ID
		 */
		public function kickUser( userID:String ):void
		{
			if( options.allowKickUser )
				participantsSOService.kickUser( userID );
		}
		
		/* INTERFACE cc.minos.bigbluebutton.plugins.users.IListeners (用戶語音狀態接口) */
		
		/**
		 * 踢出語音用戶
		 * @param	userID
		 */
		public function ejectUser( userID:Number ):void
		{
			listenersSOService.ejectUser( userID );
		}
		
		/**
		 * 靜音所有用戶
		 * @param	mute
		 */
		public function muteAllUsers( mute:Boolean ):void
		{
			listenersSOService.muteAllUsers( mute );
		}
		
		/**
		 * 設置用戶靜音狀態
		 * @param	userID
		 * @param	mute
		 */
		public function muteUnmuteUser( userID:Number, mute:Boolean ):void
		{
			listenersSOService.muteUnmuteUser( userID, mute );
		}
		
		/**
		 * 設置用戶麥克風鎖定狀態
		 * @param	userID
		 * @param	lock
		 */
		public function lockMuteUser( userID:Number, lock:Boolean ):void
		{
			listenersSOService.lockMuteUser( userID, lock );
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