package cc.minos.bigbluebutton.plugins
{
	import cc.minos.bigbluebutton.plugins.test.*;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class PortTestPlugin extends Plugin
	{
		private var protocol:String = "RTMP";
		
		public function PortTestPlugin()
		{
			super();
			this.application = "video";
			this.shortcut = 'test';
			this.name = '[PortTestPlugin]';
		}
		
		private function connectionListener( status:String, protocol:String, hostname:String, port:String, application:String ):void
		{
			
			if ( status == "SUCCESS" )
			{
				trace( "Successfully connected to: " + uri );
				bbb.conferenceParameters.protocol = protocol;
				var successEvent:PortTestEvent = new PortTestEvent( PortTestEvent.PORT_TEST_SUCCESS );
				successEvent.protocol = protocol;
				successEvent.host = hostname;
				successEvent.port = port;
				successEvent.application = application;
				dispatchEvent( successEvent );
			}
			else
			{
				trace( "Failed to connect to " + uri );
				if ( protocol == "RTMP" )
				{
					connect( "RTMPT" );
				}
				else
				{
					var failedEvent:PortTestEvent = new PortTestEvent( PortTestEvent.PORT_TEST_FAILED );
					failedEvent.protocol = protocol;
					failedEvent.host = hostname;
					failedEvent.port = port;
					failedEvent.application = application;
					dispatchEvent( failedEvent );
				}
			}
		}
		
		override public function start():void
		{
			connect( "RTMP", '1935' );
		}
		
		private function connect( protocol:String = "", port:String = "", testTimeout:Number = 10000 ):void
		{
			var portTest:PortTest = new PortTest( protocol, bbb.conferenceParameters.host, port, this.application, testTimeout );
			portTest.addConnectionSuccessListener( connectionListener );
			portTest.connect();
		}
	
	}
}