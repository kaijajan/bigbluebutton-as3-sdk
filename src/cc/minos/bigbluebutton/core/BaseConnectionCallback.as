package cc.minos.bigbluebutton.core
{
	import cc.minos.bigbluebutton.events.ConnectionFailedEvent;
	import cc.minos.bigbluebutton.events.ConnectionSuccessEvent;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class BaseConnectionCallback extends EventDispatcher
	{
		
		public function BaseConnectionCallback()
		{
		}
		
		public function onBWCheck( ... rest ):Number
		{
			return 0;
		}
		
		public function onBWDone( ... rest ):void
		{
			var p_bw:Number;
			if ( rest.length > 0 )
				p_bw = rest[ 0 ];
		}
		
		internal function onSuccess( reason:String = "" ):void
		{
			dispatchEvent( new ConnectionSuccessEvent() );
		}
		
		internal function onFailed( reason:String = "" ):void
		{
			var failedEvent:ConnectionFailedEvent = new ConnectionFailedEvent();
			failedEvent.reason = reason;
			dispatchEvent( failedEvent );
		}
	
	}
}