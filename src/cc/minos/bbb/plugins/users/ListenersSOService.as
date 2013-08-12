package cc.minos.bbb.plugins.users
{
	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class ListenersSOService extends EventDispatcher
	{
		private static const SO_NAME:String = "meetMeUsersSO";
		
		private var plugin:UsersPlugin;
		
		public function ListenersSOService( plugin:UsersPlugin )
		{
			this.plugin = plugin;
		}
		
		public function connect():void
		{
			//_listenersSO = SharedObject.getRemote( SO_NAME, plugin.uri + "/" + plugin.room, false );
			//_listenersSO.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			//_listenersSO.addEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler );
			//_listenersSO.client = this;
			//_listenersSO.connect( plugin.connection );
			//
			//notifyConnectionStatusListener( true );
			//getCurrentUsers();
			//getRoomMuteState();
		}
		
		private function netStatusHandler( e:NetStatusEvent ):void
		{
		
		}
		
		private function asyncErrorHandler( e:AsyncErrorEvent ):void
		{
		
		}
	}

}