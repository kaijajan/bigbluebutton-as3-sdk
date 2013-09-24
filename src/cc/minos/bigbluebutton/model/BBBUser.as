package cc.minos.bigbluebutton.model
{
	import cc.minos.bigbluebutton.Role;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class BBBUser
	{
		/** 用戶id */
		public var userID:String = "UNKNOWN USER";
		
		/** 外部id */
		public var externUserID:String = "UNKNOWN USER";
		
		/** 用戶名 */
		public var name:String;
		
		/** 本人 */
		public var me:Boolean = false;
		
		/** 正在說話 */
		public var talking:Boolean = false;
		
		/** 是否有視頻流 */
		private var _hasStream:Boolean = false;
		
		/** 演講者 */
		private var _presenter:Boolean = false;
		
		/** 舉手 */
		private var _raiseHand:Boolean = false;
		
		/** 用戶權限 */
		private var _role:String = Role.VIEWER;
		
		/** 用戶視頻流名稱 */
		public var streamName:String = "";
		
		/** 用戶是否正在退出 */
		public var isLeavingFlag:Boolean = false;
		
		/** 房間 */
		public var room:String = "";
		public var authToken:String = "";
		public var selected:Boolean = false;
		
		/** */
		public var voiceUserid:Number = 0;
		
		/** 是否已經加入語音聊天 */
		private var _voiceJoined:Boolean = false;
		
		/** 麥克風是否靜音 */
		private var _voiceMuted:Boolean = false;
		
		/** 麥克風是否被鎖住 */
		private var _voiceLocked:Boolean = false;
		
		/** 當前狀態 */
		public var status:Array = [];
		
		public function BBBUser()
		{
		}
		
		public function toString():String
		{
			return name
		}
		
		public function get role():String
		{
			return _role;
		}
		
		public function set role( r:String ):void
		{
			_role = r;
		}
		
		public function get presenter():Boolean
		{
			return _presenter;
		}
		
		public function set presenter( p:Boolean ):void
		{
			_presenter = p;
		}
		
		/**
		 * 整理狀態
		 * @return
		 */
		public function buildStatus():Array
		{
			status = [];
			if ( hasStream )
				status.push( "hasstream" );
			if ( voiceJoined )
				status.push( "voicejoined" );
			if ( voiceMuted )
				status.push( "voicemuted" );
			if ( voiceLocked )
				status.push( "voicelocked" );
			if ( raiseHand )
				status.push( "raisehand" );
			if ( talking )
				status.push( "talking" );
			return status;
		}
		
		public function get voiceJoined():Boolean
		{
			return _voiceJoined;
		}
		
		public function set voiceJoined( v:Boolean ):void
		{
			_voiceJoined = v;
			buildStatus();
		}
		
		public function get raiseHand():Boolean
		{
			return _raiseHand;
		}
		
		public function set raiseHand( r:Boolean ):void
		{
			_raiseHand = r;
			buildStatus();
		}
		
		public function get hasStream():Boolean
		{
			return _hasStream;
		}
		
		public function set hasStream( s:Boolean ):void
		{
			_hasStream = s;
			buildStatus();
		}
		
		public function get voiceLocked():Boolean
		{
			return _voiceLocked;
		}
		
		public function set voiceLocked( value:Boolean ):void
		{
			_voiceLocked = value;
			buildStatus();
		}
		
		public function get voiceMuted():Boolean
		{
			return _voiceMuted;
		}
		
		public function set voiceMuted( value:Boolean ):void
		{
			_voiceMuted = value;
			buildStatus();
		}
	}

}