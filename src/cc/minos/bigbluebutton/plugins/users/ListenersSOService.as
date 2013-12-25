
package cc.minos.bigbluebutton.plugins.users
{
	import cc.minos.bigbluebutton.core.BaseSOService;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class ListenersSOService extends BaseSOService
	{
		public function ListenersSOService( client:IListenersSOServiceClient )
		{
			super( client );
			this.soName = "meetMeUsersSO";
		}
		
		public function muteAllUsers( mute:Boolean ):void
		{
			sharedObject.send( "muteStateCallback", mute );
		}
	}
}