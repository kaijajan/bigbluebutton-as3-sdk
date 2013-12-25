package cc.minos.bigbluebutton.apis.resources
{
	import cc.minos.bigbluebutton.apis.responses.JoinResponse;
	
	/**
	 *
	 * @author Minos
	 */
	public class EnterResource extends Resource
	{
		static public const CALL_NAME:String = "enter";
		
		public function EnterResource( completedCallback:Function = null )
		{
			super( completedCallback );
			callName = CALL_NAME;
			requirs = [];
			response = new JoinResponse();
		}
		
		override public function get url():String
		{
			return host + callName;
		}
	
	}

}