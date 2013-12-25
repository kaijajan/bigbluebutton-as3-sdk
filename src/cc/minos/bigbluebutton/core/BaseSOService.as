
package cc.minos.bigbluebutton.core
{
	import flash.events.AsyncErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.SharedObject;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class BaseSOService
	{
		
		protected var soName:String;
		protected var sharedObject:SharedObject;
		private var client:Object;
		
		public function BaseSOService( client:Object )
		{
			this.client = client;
		}
		
		public function connect( nc:NetConnection, uri:String ):void
		{
			sharedObject = SharedObject.getRemote( soName, uri, false );
			sharedObject.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
			sharedObject.client = client;
			sharedObject.addEventListener( AsyncErrorEvent.ASYNC_ERROR, onAsyncError );
			sharedObject.connect( nc );
		}
		
		private function onNetStatus( e:NetStatusEvent ):void
		{
		
		}
		
		private function onAsyncError( e:AsyncErrorEvent ):void
		{
		
		}
		
		public function disconnect():void
		{
			if ( sharedObject != null )
				sharedObject.close();
		}
	
	}
}