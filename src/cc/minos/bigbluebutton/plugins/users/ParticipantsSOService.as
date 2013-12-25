package cc.minos.bigbluebutton.plugins.users
{
	import cc.minos.bigbluebutton.core.BaseSOService;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class ParticipantsSOService extends BaseSOService
	{
		public function ParticipantsSOService( client:IParticipantsSOServiceClient )
		{
			super( client );
			this.soName = "participantsSO";
		}
		
		public function kickUser( userID:String ):void
		{
			sharedObject.send( "kickUserCallback", userID );
		}
	}
}