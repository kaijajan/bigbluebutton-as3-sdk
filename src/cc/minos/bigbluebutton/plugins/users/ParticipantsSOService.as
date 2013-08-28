package cc.minos.bigbluebutton.plugins.users
{
	import cc.minos.bigbluebutton.events.BigBlueButtonEvent;
	import cc.minos.bigbluebutton.model.BBBUser;
	import cc.minos.bigbluebutton.plugins.UsersPlugin;
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
	public class ParticipantsSOService
	{
		private static const SO_NAME:String = "participantsSO";
		private static const GET_PARTICIPANTS:String = "participants.getParticipants";
		private static const SET_PARTICIPANT_STATUS:String = "participants.setParticipantStatus";
		private static const SET_PRESENTER:String = "participants.assignPresenter";
		
		private var responder:Responder;
		private var _participantsSO:SharedObject;
		private var plugin:UsersPlugin;
		
		public function ParticipantsSOService( plugin:UsersPlugin )
		{
			this.plugin = plugin;
			responder = new Responder( function( result:Boolean ):void
				{
				}, function( status:Object ):void
				{
				} )
		}
		
		public function connect():void
		{
			_participantsSO = SharedObject.getRemote( SO_NAME, plugin.uri, false );
			_participantsSO.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			_participantsSO.addEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler );
			_participantsSO.client = this;
			_participantsSO.connect( plugin.connection );
			queryForParticipants();
		}
		
		public function disconnect():void
		{
			if ( _participantsSO )
				_participantsSO.close();
		}
		
		private function netStatusHandler( e:NetStatusEvent ):void
		{
			trace( "participantsSO netStatus: " + e.info.code );
		}
		
		private function asyncErrorHandler( e:AsyncErrorEvent ):void
		{
			trace( "participantsSO asyncError" );
		}
		
		private function queryForParticipants():void
		{
			var nc:NetConnection = plugin.connection;
			nc.call( GET_PARTICIPANTS, new Responder( function( result:Object ):void
				{
					trace( "在線人數: " + result.count );
					if ( result.count > 0 )
					{
						for ( var p:Object in result.participants )
						{
							participantJoined( result.participants[ p ] );
						}
					}
					becomePresenterIfLoneModerator();
				}, function( status:Object ):void
				{
					plugin.dispatchRawEvent( new BigBlueButtonEvent( BigBlueButtonEvent.UNKNOWN_REASON ) );
				} ) );
		}
		
		public function participantLeft( userID:String ):void
		{
			var user:BBBUser = plugin.getUser( userID );
			if ( user != null )
			{
				user.isLeavingFlag = true;
				var leftEvent:UsersEvent = new UsersEvent( UsersEvent.LEFT );
				leftEvent.userID = userID;
				plugin.dispatchEvent( leftEvent );
				plugin.removeUser( userID );
			}
		}
		
		public function participantJoined( joinedUser:Object ):void
		{
			var user:BBBUser = new BBBUser();
			user.userID = joinedUser.userid;
			user.name = joinedUser.name;
			user.role = joinedUser.role;
			
			trace( "登陸用戶信息 [" + user.userID + "," + user.name + "," + user.role + "]" );
			plugin.addUser( user );
			
			participantStatusChange( user.userID, "hasStream", joinedUser.status.hasStream );
			participantStatusChange( user.userID, "presenter", joinedUser.status.presenter );
			participantStatusChange( user.userID, "raiseHand", joinedUser.status.raiseHand );
			
			var joinedEvent:UsersEvent = new UsersEvent( UsersEvent.JOINED )
			joinedEvent.userID = user.userID;
			plugin.dispatchEvent( joinedEvent );
		}
		
		/**
		 *
		 */
		private function becomePresenterIfLoneModerator():void
		{
			if ( plugin.hasOnlyOneModerator() )
			{
				var user:BBBUser = plugin.getTheOnlyModerator();
				if ( user )
				{
					trace( "setting presenter because only one moderator" );
					assignPresenter( user.userID, user.name, 1 );
				}
			}
		}
		
		/**
		 * 舉手
		 * @param	userID
		 * @param	raise
		 */
		public function raiseHand( userID:String, raise:Boolean ):void
		{
			plugin.connection.call( SET_PARTICIPANT_STATUS, responder, userID, "raiseHand", raise );
		}
		
		/**
		 * 添加流媒體
		 * @param	userID
		 * @param	streamName
		 */
		public function addStream( userID:String, streamName:String ):void
		{
			plugin.connection.call( SET_PARTICIPANT_STATUS, responder, userID, "hasStream", "true,stream=" + streamName );
		}
		
		/**
		 * 取消流媒體
		 * @param	userID
		 * @param	streamName
		 */
		public function removeStream( userID:String, streamName:String ):void
		{
			plugin.connection.call( SET_PARTICIPANT_STATUS, responder, userID, "hasStream", "false,stream=" + streamName );
		}
		
		/**
		 * 踢人
		 * @param	userid
		 */
		public function kickUser( userid:String ):void
		{
			_participantsSO.send( "kickUserCallback", userid );
		}
		
		/**
		 * 指定主持人
		 * @param	userid		:	用戶id
		 * @param	name		:	用戶名字
		 * @param	assignedBy	:	操作者
		 */
		public function assignPresenter( userid:String, name:String, assignedBy:Number ):void
		{
			plugin.connection.call( SET_PRESENTER, new Responder( function( result:Boolean ):void
				{
					if ( result )
					{
						trace( "Successfully assigned presenter to: " + userid );
					}
				}, function( status:Object ):void
				{
				} ), userid, name, assignedBy );
		}
		
		// callback
		
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
				var switchEvent:UsersEvent = new UsersEvent( UsersEvent.SWITCHED_PRESENTER );
				switchEvent.userID = userID;
				plugin.dispatchEvent( switchEvent );
			}
		}
		
		/**
		 * 踢人返回結果
		 * @param	userID
		 */
		public function kickUserCallback( userID:String ):void
		{
			var kickedEvent:UsersEvent = new UsersEvent( UsersEvent.KICKED );
			kickedEvent.userID = userID;
			plugin.dispatchEvent( kickedEvent );
		}
		
		/**
		 *
		 * @param	userID
		 * @param	status
		 * @param	value
		 */
		public function participantStatusChange( userID:String, status:String, value:Object ):void
		{
			trace( "狀態更新 [" + userID + "," + status + "," + value + "]" );
			plugin.newUserStatus( userID, status , value );
		}
	}

}