package cc.minos.bigbluebutton.plugins.users
{
	import cc.minos.bigbluebutton.model.BBBUser;
	import cc.minos.bigbluebutton.plugins.UsersPlugin;
	import flash.events.AsyncErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.SharedObject;
	
	/**
	 * 語音狀態控制
	 * @author Minos
	 */
	public class ListenersSOService implements IListenersCallback
	{
		/** 用戶語音狀態 */
		private const SO_NAME:String = "meetMeUsersSO";
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
		
		private var plugin:UsersPlugin;
		private var _listenersSO:SharedObject;
		private var responder:Responder;
		private var connection:NetConnection;
		
		public function ListenersSOService( plugin:UsersPlugin )
		{
			this.plugin = plugin;
			responder = new Responder( function( result:Object ):void
				{
				}, function( status:Object ):void
				{
				} );
		}
		
		public function connect():void
		{
			connection = plugin.connection;
			_listenersSO = SharedObject.getRemote( SO_NAME, plugin.uri, false );
			_listenersSO.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			_listenersSO.addEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler );
			_listenersSO.client = this;
			_listenersSO.connect( connection );
			
			getCurrentUsers();
			getRoomMuteState();
		}
		
		public function disconnect():void
		{
			if ( _listenersSO )
				_listenersSO.close();
		}
		
		/**
		 * 獲取當前加入語音列表的用戶
		 */
		private function getCurrentUsers():void
		{
			connection.call( GET_MEETMEUSERS, new Responder( function( result:Object ):void
				{
					if ( result.count > 0 )
					{
						for ( var p:Object in result.participants )
						{
							var u:Object = result.participants[ p ]
							userJoin( u.participant, u.name, u.name, u.muted, u.talking, u.locked );
						}
					}
				}, function( status:Object ):void
				{
					trace( SO_NAME + " getCurrentUsers error" );
				} ) );
		}
		
		/**
		 * 語音用戶加入
		 * @param	userId
		 * @param	cidName
		 * @param	cidNum
		 * @param	muted
		 * @param	talking
		 * @param	locked
		 */
		public function userJoin( userID:Number, cidName:String, cidNum:String, muted:Boolean, talking:Boolean, locked:Boolean ):void
		{
			trace( "語音用戶加入 [" + cidName + "]" );
			if ( cidName )
			{
				var pattern:RegExp = /(.*)-bbbID-(.*)$/;
				var result:Object = pattern.exec( cidName );
				
				if ( result != null )
				{
					if ( plugin.hasUser( result[ 1 ] ) )
					{
						//更新用戶語音信息
						var bu:BBBUser = plugin.getUser( result[ 1 ] );
						bu.voiceUserid = userID;
						bu.voiceMuted = muted;
						bu.voiceJoined = true;
						
						sendListenerEvent( UsersEvent.USER_VOICE_JOINED, bu.userID );
					}
				}
			}
		}
		
		/**
		 * 設置用戶靜音
		 * @param	userID
		 * @param	mute
		 */
		public function userMute( userID:Number, mute:Boolean ):void
		{
			var user:BBBUser = plugin.getVoiceUser( userID );
			if ( user != null )
			{
				user.voiceMuted = mute;
				if ( user.voiceMuted )
				{
					userTalk( userID, false );
				}
				sendListenerEvent( UsersEvent.USER_VOICE_MUTED, user.userID );
			}
		}
		
		/**
		 * 鎖定用戶麥克風
		 * @param	userID
		 * @param	locked
		 */
		public function userLockedMute( userID:Number, locked:Boolean ):void
		{
			var user:BBBUser = plugin.getVoiceUser( userID );
			if ( user != null )
			{
				user.voiceLocked = locked;
				sendListenerEvent( UsersEvent.USER_VOICE_LOCKED, user.userID );
			}
		}
		
		/**
		 * 用戶是否存在音頻流
		 * @param	userID
		 * @param	talk
		 */
		public function userTalk( userID:Number, talk:Boolean ):void
		{
			var user:BBBUser = plugin.getVoiceUser( userID );
			if ( user != null )
			{
				user.talking = talk;
				sendListenerEvent( UsersEvent.USER_VOICE_TALKING, user.userID );
			}
		
		}
		
		/**
		 * 語音用戶離開
		 * @param	userID
		 */
		public function userLeft( userID:Number ):void
		{
			var user:BBBUser = plugin.getVoiceUser( userID );
			if ( user != null )
			{
				user.voiceJoined = false;
				user.voiceUserid = 0;
				user.talking = false
				user.voiceMuted = false;
				user.voiceLocked = false;
				
				sendListenerEvent( UsersEvent.USER_VOICE_LEFT, user.userID );
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
		
		/**
		 * 設置語音用戶麥克風鎖定狀態
		 * @param	userid
		 * @param	lock
		 */
		public function lockMuteUser( userid:Number, lock:Boolean ):void
		{
			connection.call( SET_LOCK_USER, responder, userid, lock );
		}
		
		/**
		 * 設置語音用戶麥克風靜音狀態
		 * @param	userid
		 * @param	mute
		 */
		public function muteUnmuteUser( userid:Number, mute:Boolean ):void
		{
			connection.call( SET_MUTE_USER, responder, userid, mute );
		}
		
		/**
		 * 設置所有用戶靜音狀態
		 * @param	mute
		 */
		public function muteAllUsers( mute:Boolean ):void
		{
			connection.call( SET_MUTE_ALL_USER, responder, mute );
			_listenersSO.send( "muteStateCallback", mute );
		}
		
		/**
		 * 設置狀態返回
		 * @param	mute
		 */
		public function muteStateCallback( mute:Boolean ):void
		{
			var e:UsersEvent = new UsersEvent( UsersEvent.ROOM_MUTE_STATE );
			e.mute = mute;
			plugin.dispatchEvent( e );
		}
		
		/**
		 * 踢出語音用戶
		 * @param	userId
		 */
		public function ejectUser( userId:Number ):void
		{
			connection.call( SET_KILL_USER, responder, userId );
		}
		
		/**
		 * 獲取狀態
		 */
		private function getRoomMuteState():void
		{
			connection.call( GET_ROOMMUTED_STATE, new Responder( function( result:Object ):void
				{
					muteStateCallback( result as Boolean );
				}, function( status:Object ):void
				{
					trace( SO_NAME + " getRoomMuteState error" );
				} ) );
		}
		
		private function netStatusHandler( e:NetStatusEvent ):void
		{
			trace( SO_NAME + ": " + e.info.code );
		}
		
		private function asyncErrorHandler( e:AsyncErrorEvent ):void
		{
			trace( SO_NAME + " async error" );
		}
		
		private function sendListenerEvent( type:String, userID:String ):void
		{
			var event:UsersEvent = new UsersEvent( type );
			event.userID = userID;
			plugin.dispatchEvent( event );
		}
	
	}

}