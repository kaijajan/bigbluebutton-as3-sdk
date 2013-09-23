package cc.minos.bigbluebutton.plugins.users
{
	import cc.minos.bigbluebutton.model.BBBUser;
	import cc.minos.bigbluebutton.plugins.UsersPlugin;
	import cc.minos.utils.RandomUtil;
	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.SharedObject;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class ListenersSOService extends EventDispatcher
	{
		private const SO_NAME:String = "meetMeUsersSO";
		private const GET_MEETMEUSERS:String = "voice.getMeetMeUsers";
		private const GET_ROOMMUTED_STATE:String = "voice.isRoomMuted";
		private const SET_LOCK_USER:String = "voice.lockMuteUser";
		private const SET_MUTE_USER:String = "voice.muteUnmuteUser";
		private const SET_MUTE_ALL_USER:String = "voice.muteAllUsers";
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
		 *
		 * @param	userId
		 * @param	cidName
		 * @param	cidNum
		 * @param	muted
		 * @param	talking
		 * @param	locked
		 */
		public function userJoin( userID:Number, cidName:String, cidNum:String, muted:Boolean, talking:Boolean, locked:Boolean ):void
		{
			trace( "voice user joining [" + cidName + "]" );
			if ( cidName )
			{
				var pattern:RegExp = /(.*)-bbbID-(.*)$/;
				var result:Object = pattern.exec( cidName );
				
				if ( result != null )
				{
					if ( plugin.hasUser( result[ 1 ] ) )
					{
						var bu:BBBUser = plugin.getUser( result[ 1 ] );
						bu.voiceUserid = userID;
						bu.voiceMuted = muted;
						bu.voiceJoined = true;
						
						sendListenerEvent( UsersEvent.USER_VOICE_JOINED, bu.userID );
					}
				}
			}
		}
		
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
		
		public function userLockedMute( userID:Number, locked:Boolean ):void
		{
			var user:BBBUser = plugin.getVoiceUser( userID );
			if ( user != null )
			{
				user.voiceLocked = locked;
				sendListenerEvent( UsersEvent.USER_VOICE_LOCKED, user.userID );
			}
		}
		
		public function userTalk( userID:Number, talk:Boolean ):void
		{
			var user:BBBUser = plugin.getVoiceUser( userID );
			if ( user != null )
			{
				user.talking = talk;
				
				sendListenerEvent( UsersEvent.USER_VOICE_TALKING, user.userID );
			}
		
		}
		
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
		
		public function lockMuteUser( userid:Number, lock:Boolean ):void
		{
			connection.call( SET_LOCK_USER, responder, userid, lock );
		}
		
		public function muteUnmuteUser( userid:Number, mute:Boolean ):void
		{
			connection.call( SET_MUTE_USER, responder, userid, mute );
		}
		
		public function muteAllUsers( mute:Boolean ):void
		{
			connection.call( SET_MUTE_ALL_USER, responder, mute );
			_listenersSO.send( "muteStateCallback", mute );
		}
		
		/**
		 *
		 * @param	mute
		 */
		public function muteStateCallback( mute:Boolean ):void
		{
			var e:UsersEvent = new UsersEvent( UsersEvent.ROOM_MUTE_STATE );
			e.mute = mute;
			plugin.dispatchEvent( e );
		}
		
		/**
		 *
		 * @param	userId
		 */
		public function ejectUser( userId:Number ):void
		{
			connection.call( SET_KILL_USER, responder, userId );
		}
		
		/**
		 *
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