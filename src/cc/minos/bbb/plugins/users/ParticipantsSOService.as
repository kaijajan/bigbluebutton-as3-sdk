package cc.minos.bbb.plugins.users
{
	import cc.minos.bbb.BBBUser;
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
	public class ParticipantsSOService extends EventDispatcher
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
			_participantsSO = SharedObject.getRemote( SO_NAME, plugin.uri + "/" + plugin.room, false );
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
		}
		
		private function queryForParticipants():void
		{
			var nc:NetConnection = plugin.connection;
			nc.call( GET_PARTICIPANTS, // Remote function name
				new Responder( function( result:Object ):void
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
				//sendConnectionFailedEvent( ConnectionFailedEvent.UNKNOWN_REASON );
				} ) );
		}
		
		public function participantLeft( userID:String ):void
		{
			var user:BBBUser = plugin.getUser( userID );
			if ( user != null )
			{
				user.isLeavingFlag = true;
				var leftEvent:PariticipantEvent = new PariticipantEvent( PariticipantEvent.LEFT );
				leftEvent.userID = userID;
				dispatchEvent( leftEvent );
				
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
			
			participantStatusChange( user.userID, "hasStream", joinedUser.status.hasStream );
			participantStatusChange( user.userID, "presenter", joinedUser.status.presenter );
			participantStatusChange( user.userID, "raiseHand", joinedUser.status.raiseHand );
			
			plugin.addUser( user );
			
			var joinedEvent:PariticipantEvent = new PariticipantEvent( PariticipantEvent.JOINED )
			joinedEvent.userID = user.userID;
			dispatchEvent( joinedEvent );
		}
		
		/**
		 *
		 */
		private function becomePresenterIfLoneModerator():void
		{
		}
		
		/**
		 * 舉手
		 * @param	userID
		 * @param	raise
		 */
		public function raiseHand( userID:String, raise:Boolean ):void
		{
			var nc:NetConnection = plugin.connection;
			nc.call( SET_PARTICIPANT_STATUS, // Remote function name
				responder, userID, "raiseHand", raise ); //_netConnection.call
		}
		
		/**
		 * 添加流媒體
		 * @param	userID
		 * @param	streamName
		 */
		public function addStream( userID:String, streamName:String ):void
		{
			var nc:NetConnection = plugin.connection;
			nc.call( SET_PARTICIPANT_STATUS, // Remote function name
				responder, userID, "hasStream", "true,stream=" + streamName ); //_netConnection.call
		}
		
		/**
		 * 取消流媒體
		 * @param	userID
		 * @param	streamName
		 */
		public function removeStream( userID:String, streamName:String ):void
		{
			var nc:NetConnection = plugin.connection;
			nc.call( SET_PARTICIPANT_STATUS, // Remote function name
				responder, userID, "hasStream", "false,stream=" + streamName ); //_netConnection.call
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
			var nc:NetConnection = plugin.connection;
			nc.call( SET_PRESENTER, new Responder( function( result:Boolean ):void
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
			//var endMeetingEvent:BBBEvent = new BBBEvent( BBBEvent.END_MEETING_EVENT );
			//dispatcher.dispatchEvent( endMeetingEvent );
		}
		
		/**
		 * 指定主持人返回結果
		 * @param	userID
		 * @param	name
		 * @param	assignedBy
		 */
		public function assignPresenterCallback( userID:String, name:String, assignedBy:String ):void
		{
		
		}
		
		/**
		 * 踢人返回結果
		 * @param	userID
		 */
		public function kickUserCallback( userID:String ):void
		{
			var kickedEvent:PariticipantEvent = new PariticipantEvent( PariticipantEvent.KICKED );
			kickedEvent.userID = userID;
			dispatchEvent( kickedEvent );
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
			
			if ( status == "presenter" )
			{
				trace( "更新主持人" );
			}
		}
	}

}