package cc.minos.bbb.plugins.users
{
	import cc.minos.bbb.BBBUser;
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
	public class ListenersSOService extends EventDispatcher implements IListenersCallback
	{
		private static const SO_NAME:String = "meetMeUsersSO";
		private static const GET_MEETMEUSERS:String = "voice.getMeetMeUsers";
		private static const GET_ROOMMUTED_STATE:String = "voice.isRoomMuted";
		
		private var plugin:UsersPlugin;
		private var _listenersSO:SharedObject;
		private var connection:NetConnection;
		private var uri:String;
		
		public function ListenersSOService( plugin:UsersPlugin )
		{
			this.plugin = plugin;
		}
		
		public function connect():void
		{
			connection = plugin.connection;
			uri = plugin.uri + "/" + plugin.room;
			
			_listenersSO = SharedObject.getRemote( SO_NAME, uri, false );
			_listenersSO.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			_listenersSO.addEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler );
			_listenersSO.client = this;
			_listenersSO.connect( connection );
			
			//notifyConnectionStatusListener( true );
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
						
						var joinedEvent:ListenerEvent = new ListenerEvent( ListenerEvent.USER_VOICE_JOINED );
						joinedEvent.userid = bu.userID;
						dispatchEvent( joinedEvent );
					}
						//var bbbEvent:BBBEvent = new BBBEvent( BBBEvent.USER_VOICE_JOINED );
						//bbbEvent.payload.userID = bu.userID;
						//globalDispatcher.dispatchEvent( bbbEvent );
				}
				else
				{
					var n:BBBUser = new BBBUser();
					n.name = cidName;
					n.userID = RandomUtil.randomString( 11 );
					n.externUserID = RandomUtil.randomString( 11 );
					n.phoneUser = true;
					n.talking = talking
					n.voiceMuted = muted;
					n.voiceUserid = userID;
					n.voiceJoined = true;
					
						//_conference.addUser( n );
				}
			}
		}
		
		public function userMute(userID:Number, mute:Boolean):void {
			var user:BBBUser = plugin.getVoiceUser( userID );
			if ( user != null )
			{
				user.voiceMuted = mute;
				if ( user.voiceMuted )
				{
					userTalk( userID, false );
				}
				sendListenerEvent( ListenerEvent.USER_VOICE_MUTED, user.userID );
			}
		}
		
		public function userLockedMute(userID:Number, locked:Boolean):void {
			var user:BBBUser = plugin.getVoiceUser( userID );
			if ( user != null )
			{
				user.voiceLocked = locked;
				sendListenerEvent( ListenerEvent.USER_VOICE_LOCKED, user.userID );
			}
		}
		
		public function userTalk( userID:Number, talk:Boolean ):void
		{
			var user:BBBUser = plugin.getVoiceUser( userID );
			if ( user != null )
			{
				user.talking = talk;
				
				sendListenerEvent( ListenerEvent.USER_VOICE_TALKING , user.userID );
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
				
				sendListenerEvent( ListenerEvent.USER_VOICE_LEFT , user.userID );
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
			connection.call( "voice.lockMuteUser", // Remote function name
				new Responder( 
				// participants - On successful result
				function( result:Object ):void
				{
					trace( "Successfully lock mute/unmute: " + userid );
				}, 
				// status - On error occurred
				function( status:Object ):void
				{
				//LogUtil.error("Error occurred:"); 
				//for (var x:Object in status) { 
				//LogUtil.error(x + " : " + status[x]); 
				//} 
				} ), //new Responder
				userid, lock ); //_netConnection.call		
		}
		
		public function muteUnmuteUser( userid:Number, mute:Boolean ):void
		{
			connection.call( "voice.muteUnmuteUser", // Remote function name
				new Responder( 
				// participants - On successful result
				function( result:Object ):void
				{
					trace( "Successfully mute/unmute: " + userid );
				}, 
				// status - On error occurred
				function( status:Object ):void
				{
				//LogUtil.error("Error occurred:"); 
				//for (var x:Object in status) { 
				//LogUtil.error(x + " : " + status[x]); 
				//} 
				} ), //new Responder
				userid, mute ); //_netConnection.call		
		}
		
		public function muteAllUsers( mute:Boolean ):void
		{
			connection.call( "voice.muteAllUsers", // Remote function name
				new Responder( 
				// participants - On successful result
				function( result:Object ):void
				{
					trace( "Successfully mute/unmute all users: " );
				}, 
				// status - On error occurred
				function( status:Object ):void
				{
				//LogUtil.error("Error occurred:"); 
				//for (var x:Object in status) { 
				//LogUtil.error(x + " : " + status[x]); 
				//} 
				} ), //new Responder
				mute ); //_netConnection.call		
			_listenersSO.send( "muteStateCallback", mute );
		}
		
		public function muteStateCallback( mute:Boolean ):void
		{
			var e:ListenerEvent = new ListenerEvent( ListenerEvent.ROOM_MUTE_STATE );
			e.mute = mute;
			dispatchEvent( e );
		}
		
		public function ejectUser( userId:Number ):void
		{
			connection.call( "voice.kickUSer", // Remote function name
				new Responder( 
				// participants - On successful result
				function( result:Object ):void
				{
					trace( "Successfully kick user: userId" );
				}, 
				// status - On error occurred
				function( status:Object ):void
				{
				//LogUtil.error("Error occurred:"); 
				//for (var x:Object in status) { 
				//LogUtil.error(x + " : " + status[x]); 
				//} 
				} ), //new Responder
				userId ); //_netConnection.call		
		}
		
		private function getRoomMuteState():void
		{
			connection.call( GET_ROOMMUTED_STATE, new Responder( function( result:Object ):void
				{
					var e:ListenerEvent = new ListenerEvent( ListenerEvent.ROOM_MUTE_STATE );
					e.mute = result as Boolean;
					dispatchEvent( e );
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
		
		private function sendListenerEvent( type:String , userID:String ):void
		{
			var event:ListenerEvent = new ListenerEvent( type );
			event.userid = userID;
			dispatchEvent( event );
		}
		
	}

}