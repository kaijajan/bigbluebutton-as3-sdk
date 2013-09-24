package cc.minos.bigbluebutton.plugins
{
	import cc.minos.bigbluebutton.plugins.test.*;
	
	/**
	 * 端口測試應用（非必須）
	 * 根據測試設定連接的協議
	 * @author Minos
	 */
	public class PortTestPlugin extends Plugin
	{
		
		public function PortTestPlugin()
		{
			super();
			this.application = "video/portTest";
			this.shortcut = 'test';
			this.name = '[PortTestPlugin]';
		}
		
		/**
		 * 測試返回結果處理
		 * @param	status			:	狀態（成功|失敗）
		 * @param	protocol		:	協議
		 * @param	hostname		:	服務器地址
		 * @param	port			:	端口
		 * @param	application		:	應用地址
		 */
		private function connectionListener( status:String, protocol:String, hostname:String, port:String, application:String ):void
		{
			
			if ( status == "SUCCESS" )
			{
				trace( "服務器測試成功: " + uri );
				this.protocol = protocol;
				var successEvent:PortTestEvent = new PortTestEvent( PortTestEvent.PORT_TEST_SUCCESS );
				successEvent.protocol = protocol;
				successEvent.host = hostname;
				successEvent.port = port;
				successEvent.application = application;
				dispatchEvent( successEvent );
			}
			else
			{
				trace( "連接失敗: " + uri );
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
		
		/**
		 * 開始測試
		 */
		override public function start():void
		{
			connect( protocol, '1935' );
		}
		
		/**
		 * 測試
		 * @param	protocol		:	協議
		 * @param	port			:	端口
		 * @param	testTimeout		:	等待響應時間
		 */
		private function connect( protocol:String = "", port:String = "", testTimeout:Number = 10000 ):void
		{
			this.protocol = protocol;
			var portTest:PortTest = new PortTest( protocol, bbb.conferenceParameters.host, port, this.application, testTimeout );
			portTest.addConnectionSuccessListener( connectionListener );
			portTest.connect();
		}
		
		/**
		 * 獲取協議（主類配置參數）
		 */
		public function get protocol():String
		{
			return bbb.conferenceParameters.protocol;
		}
		
		/**
		 * 設置協議（主類配置參數）
		 */
		public function set protocol( value:String ):void
		{
			bbb.conferenceParameters.protocol = value;
		}
	
	}
}