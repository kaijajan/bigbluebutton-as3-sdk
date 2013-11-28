package cc.minos.bigbluebutton.plugins.users
{
	import cc.minos.bigbluebutton.model.BBBUser;
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
		
		private var plugin:IUsersManager;
		private var _listenersSO:SharedObject;
		
		public function ListenersSOService( plugin:IUsersManager )
		{
			this.plugin = plugin;
		}
		
		public function connect( connection:NetConnection , uri:String ):void
		{
			_listenersSO = SharedObject.getRemote( SO_NAME, uri, false );
			_listenersSO.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			_listenersSO.addEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler );
			_listenersSO.client = this;
			_listenersSO.connect( connection );
			
		}
		
		public function disconnect():void
		{
			if ( _listenersSO )
				_listenersSO.close();
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
						bu.talking = talking;
						bu.voiceLocked = locked;
						
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
		 * 設置所有用戶靜音狀態
		 * @param	mute
		 */
		public function muteAllUsers( mute:Boolean ):void
		{
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
		 * 獲取狀態
		 */
		
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
			
			var changedEvent:UsersEvent = new UsersEvent( UsersEvent.USER_STATES_CHANGED );
			changedEvent.userID = userID;
			plugin.dispatchEvent( changedEvent );
		}
	
	}

}