package cc.minos.bigbluebutton.apis.responses
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public class Response
	{
		
		protected var xml:XML;
		
		public function Response()
		{
		}
		
		public function load( data:* ):void
		{
			xml = new XML( data );
		}
		
		public function get data():XML
		{
			return xml;
		}
		
		public function get returncode():String
		{
			return xml.returncode;
		}
		
		public function get message():String
		{
			return xml.message;
		}
		
		public function get logoutURL():String
		{
			return xml.logoutURL;
		}
	
	}

}