package cc.minos.bigbluebutton.plugins.users
{
	import cc.minos.bigbluebutton.events.BigBlueButtonEvent;
	import cc.minos.bigbluebutton.events.MadePresenterEvent;
	import cc.minos.bigbluebutton.model.BBBUser;
	import cc.minos.console.Console;
	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.SharedObject;
	
	/**
	 * 在線用戶狀態
	 * @author Minos
	 */
	public class ParticipantsSOService implements IParticipantsCallback
	{
		/** 用戶狀態 */
		private static const SO_NAME:String = "participantsSO";
		
		private var _participantsSO:SharedObject;
		private var plugin:UsersPlugin;
		
		public function ParticipantsSOService( plugin:UsersPlugin )
		{
			this.plugin = plugin;
		}
		
		/**
		 * 連接用戶狀態服務
		 */
		public function connect():void
		{
			_participantsSO = SharedObject.getRemote( SO_NAME, plugin.uri, false );
			_participantsSO.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			_participantsSO.addEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler );
			_participantsSO.client = this;
			_participantsSO.connect( plugin.connection );
		}
		
		/**
		 * 斷開服務
		 */
		public function disconnect():void
		{
			if ( _participantsSO )
				_participantsSO.close();
		}
		
		private function netStatusHandler( e:NetStatusEvent ):void
		{
			//trace( "participantsSO netStatus: " + e.info.code );
		}
		
		private function asyncErrorHandler( e:AsyncErrorEvent ):void
		{
			//trace( "participantsSO asyncError" );
		}
		
		/**
		 *
		 * @param	type
		 * @param	userID
		 */
		private function sendParticipantsEvent( type:String, userID:String ):void
		{
			var event:UsersEvent = new UsersEvent( type );
			event.userID = userID;
			plugin.dispatchEvent( event );
		}
		
		/**
		 * 踢人
		 * @param	userID		:	用戶ID
		 */
		public function kickUser( userID:String ):void
		{
			_participantsSO.send( "kickUserCallback", userID );
		}
		
		/** cc.minos.bigbluebutton.plugins.users.IParticipantsCallback (服務器返回接口) */
		
		/**
		 * 用戶離開
		 * @param	userID		:	用戶ID
		 */
		public function participantLeft( userID:String ):void
		{
			var user:BBBUser = plugin.getUser( userID );
			if ( user != null )
			{
				user.isLeavingFlag = true;
				sendParticipantsEvent( UsersEvent.LEFT, userID );
				plugin.removeUser( userID );
			}
		}
		
		/**
		 * 用戶加入
		 * @param	joinedUser		:	用戶信息
		 */
		public function participantJoined( joinedUser:Object ):void
		{
			var user:BBBUser = new BBBUser();
			user.userID = joinedUser.userid;
			user.name = joinedUser.name;
			user.role = joinedUser.role;
			user.externUserID = joinedUser.externUserID;
			user.isLeavingFlag = false;
			
			trace( "User Joined [" + user.userID + "," + user.name + "," + user.role + "]" );
			plugin.addUser( user );
			
			/** 更新 */
			participantStatusChange( user.userID, "hasStream", joinedUser.status.hasStream );
			participantStatusChange( user.userID, "presenter", joinedUser.status.presenter );
			participantStatusChange( user.userID, "raiseHand", joinedUser.status.raiseHand );
			
			sendParticipantsEvent( UsersEvent.JOINED, user.userID );
		}
		
		/**
		 *
		 */
		public function logout():void
		{
			var event:BigBlueButtonEvent = new BigBlueButtonEvent( BigBlueButtonEvent.USER_LOGGED_OUT );
			plugin.dispatchRawEvent( event );
		}
		
		/**
		 * 指定主持人返回結果
		 * @param	userID
		 * @param	name
		 * @param	assignedBy
		 */
		public function assignPresenterCallback( userID:String, name:String, assignedBy:String ):void
		{
			var user:BBBUser = plugin.getUser( userID );
			if ( user )
			{
				var madeEvent:MadePresenterEvent = new MadePresenterEvent( MadePresenterEvent.PRESENTER_NAME_CHANGE );
				madeEvent.userID = userID;
				madeEvent.presenterName = name;
				madeEvent.assignerBy = assignedBy;
				plugin.dispatchRawEvent( madeEvent );
			}
		}
		
		/**
		 * 踢人返回結果
		 * @param	userID
		 */
		public function kickUserCallback( userID:String ):void
		{
			sendParticipantsEvent( UsersEvent.KICKED, userID );
		}
		
		/**
		 * 更新用戶狀態
		 * @param	userID
		 * @param	status
		 * @param	value
		 */
		public function participantStatusChange( userID:String, status:String, value:Object ):void
		{
			trace( "狀態更新 [" + userID + "," + status + "," + value + "]" );
			var aUser:BBBUser = plugin.getUser( userID );
			if ( aUser != null )
			{
				switch ( status )
				{
					case "presenter": 
						aUser.presenter = value as Boolean;
						//sendParticipantsEvent( UsersEvent., aUser.userID );
						break;
					case "hasStream": 
						var streamInfo:Array = String( value ).split( /,/ );
						aUser.hasStream = ( String( streamInfo[ 0 ] ).toUpperCase() == "TRUE" );
						var streamNameInfo:Array = String( streamInfo[ 1 ] ).split( /=/ );
						aUser.streamName = streamNameInfo[ 1 ];
						if ( aUser.hasStream )
						{
							sendParticipantsEvent( UsersEvent.USER_VIDEO_STREAM_STARTED, aUser.userID );
						}else {
							if ( aUser.streamName != null ) {
								aUser.streamName = null;
								sendParticipantsEvent( UsersEvent.USER_VIDEO_STREAM_STOPED, aUser.userID );
							}
						}
						break;
					case "raiseHand": 
						aUser.raiseHand = value as Boolean;
						sendParticipantsEvent( UsersEvent.RAISE_HAND, aUser.userID );
						break;
				}
				aUser.buildStatus();
				plugin.refresh();
			}
		
		}
	
	}

}