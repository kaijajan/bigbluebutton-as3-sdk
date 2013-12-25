package cc.minos.bigbluebutton.plugins.test
{
	import cc.minos.bigbluebutton.events.PortTestEvent;
	import cc.minos.bigbluebutton.plugins.Plugin;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class TestPlugin extends Plugin
	{
		protected var protocol:String;
		
		public function TestPlugin()
		{
			super()
			this._application = "video/portTest";
			this._name = "[PortTest]";
			this._shortcut = "test";
		}
		
		private function connect( protocol:String, port:String = "", testTimeout:Number = 10000 ):void
		{
			this.protocol = protocol;
			var portTest:PortTest = new PortTest( protocol, bbb.config.host, port, this.application, testTimeout );
			portTest.addConnectionSuccessListener( onTestCallback );
			portTest.connect();
		}
		
		private function onTestCallback( status:String, protocol:String, hostname:String, port:String, application:String ):void
		{
			if ( status == "SUCCESS" )
			{
				dispatchRawEvent( new PortTestEvent( PortTestEvent.PORT_TEST_SUCCESS ) );
			}
			else if ( status == "FAILED" )
			{
				if ( protocol == "rtmp" )
				{
					connect( "rtmpt" )
				}
				else
				{
					dispatchRawEvent( new PortTestEvent( PortTestEvent.PORT_TEST_FAILED ) );
				}
				
			}
		}
		
		override public function start():void
		{
			connect( "rtmp", "1935" );
		}
	
	}
}