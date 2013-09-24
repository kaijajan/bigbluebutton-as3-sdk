package cc.minos.bigbluebutton.plugins.users
{
	import cc.minos.bigbluebutton.events.BigBlueButtonEvent;
	import cc.minos.bigbluebutton.model.BBBUser;
	import cc.minos.bigbluebutton.plugins.UsersPlugin;
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
		/** 獲取在線用戶數據 */
		private static const GET_PARTICIPANTS:String = "participants.getParticipants";
		/** 設置用戶狀態 */
		private static const SET_PARTICIPANT_STATUS:String = "participants.setParticipantStatus";
		/** 設置演講者 */
		private static const SET_PRESENTER:String = "participants.assignPresenter";
		
		/** 返回處理 */
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
			queryForParticipants();
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
			trace( "participantsSO netStatus: " + e.info.code );
		}
		
		private function asyncErrorHandler( e:AsyncErrorEvent ):void
		{
			trace( "participantsSO asyncError" );
		}
		
		/**
		 * 獲取在線用戶數據
		 */
		private function queryForParticipants():void
		{
			plugin.connection.call( GET_PARTICIPANTS, new Responder( function( result:Object ):void
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
		 * 當房間只有一個管理員的時候設為演講者
		 */
		private function becomePresenterIfLoneModerator():void
		{
			if ( plugin.hasOnlyOneModerator() )
			{
				var user:BBBUser = plugin.getTheOnlyModerator();
				if ( user )
				{
					assignPresenter( user.userID, user.name, 1 );
				}
			}
		}
		
		/**
		 * 舉手
		 * @param	userID		:	用戶ID
		 * @param	raise		:	是否舉手(true|false)
		 */
		public function raiseHand( userID:String, raise:Boolean ):void
		{
			plugin.connection.call( SET_PARTICIPANT_STATUS, responder, userID, "raiseHand", raise );
		}
		
		/**
		 * 添加流媒體
		 * @param	userID		:	用戶ID
		 * @param	streamName	:	視頻流名稱
		 */
		public function addStream( userID:String, streamName:String ):void
		{
			plugin.connection.call( SET_PARTICIPANT_STATUS, responder, userID, "hasStream", "true,stream=" + streamName );
		}
		
		/**
		 * 取消流媒體
		 * @param	userID		:	用戶ID
		 * @param	streamName	:	視頻流名稱
		 */
		public function removeStream( userID:String, streamName:String ):void
		{
			plugin.connection.call( SET_PARTICIPANT_STATUS, responder, userID, "hasStream", "false,stream=" + streamName );
		}
		
		/**
		 * 踢人
		 * @param	userID		:	用戶ID
		 */
		public function kickUser( userID:String ):void
		{
			_participantsSO.send( "kickUserCallback", userID );
		}
		
		/**
		 * 指定主持人
		 * @param	userid		:	用戶id
		 * @param	name		:	用戶名字
		 * @param	assignedBy	:	操作者
		 */
		public function assignPresenter( userid:String, name:String, assignedBy:Number ):void
		{
			plugin.connection.call( SET_PRESENTER, responder, userid, name, assignedBy );
		}
		
		/** cc.minos.bigbluebutton.plugins.users.IParticipantsCallback (服務器返回接口) */
		
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
				sendParticipantsEvent( UsersEvent.SWITCHED_PRESENTER, userID );
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
						sendParticipantsEvent( UsersEvent.PRESENTER_NAME_CHANGE, aUser.userID );
						break;
					case "hasStream": 
						var streamInfo:Array = String( value ).split( /,/ );
						aUser.hasStream = ( String( streamInfo[ 0 ] ).toUpperCase() == "TRUE" );
						var streamNameInfo:Array = String( streamInfo[ 1 ] ).split( /=/ );
						aUser.streamName = streamNameInfo[ 1 ];
						if ( aUser.hasStream )
						{
							sendParticipantsEvent( UsersEvent.USER_VIDEO_STREAM_STARTED, aUser.userID );
						}
						break;
					case "raiseHand": 
						aUser.raiseHand = value as Boolean;
						break;
				}
				aUser.buildStatus();
				plugin.refresh();
			}
		
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
	}

}