package cc.minos.bigbluebutton.apis.resources
{
	import cc.minos.bigbluebutton.apis.responses.Response;
	import cc.minos.bigbluebutton.apis.utils.SHA1;
	import cc.minos.console.Console;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.navigateToURL;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Timer;

	/**
	 * ...
	 * @author Minos
	 */
	public class Resource
	{
		protected var host:String = "";
		protected var securitySalt:String = "";
		protected var callName:String = "";
		protected var requirs:Array = [ "meetingID" ];
		protected var _meetingID:String;

		protected var request:URLRequest;
		protected var loader:URLLoader;

		protected var params:Object = {};

		protected var calling:Boolean = false;
		protected var completedCallback:Function = null;
		protected var response:Response;

		//
		protected var tryTimer:Timer;

		public function Resource( completedCallback:Function = null )
		{
			this.completedCallback = completedCallback;
			//tryTimer = new Timer( 3 * 1000 , 1);
			//tryTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTryTimer );
		}

		private function onTryTimer( e:TimerEvent ):void
		{
			//call(this.host, this.securitySalt);
			loader.load( request );
			Console.log( '[API] call: ' + request.url );
		}

		public function call( host:String, securitySalt:String ):void
		{
			if ( calling )
				return;

			this.securitySalt = securitySalt;
			this.host = host;
			checkParams();

			var querys:String = getQueryString();
			var checksum:String = callName + querys + securitySalt;

			checksum = SHA1.hash( checksum );
			setQuery( "checksum", checksum );

			request = new URLRequest( url );
			//request.method = URLRequestMethod.POST;

			Console.log( '[API] call: ' + request.url );

			loader = new URLLoader();
			loader.addEventListener( Event.COMPLETE, onComplete );
			loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, onHttpStatus );
			loader.addEventListener( IOErrorEvent.IO_ERROR, onIoError );
			loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
			loader.load( request );

			calling = true;
		}

		public function get url():String
		{
			return host + callName + "?" + getQueryString();
		}

		protected function getQueryString():String
		{
			var query:String = "";
			for ( var p:Object in params )
			{
				if ( params[ p ] != null )
				{
					if ( p.toString() == "meta" )
					{
						var metas:Array = params[ p ].toString().split( ";" );
						for ( var i:int = 0; i < metas.length; i++ )
						{
							var obs:Array = metas[ i ].split( ":" );
							query += "&meta_" + obs[ 0 ] + "=" + encodeURI( obs[ 1 ] );
						}
					}
					else
					{
						query += "&" + p.toString() + "=" + encodeURI( params[ p ].toString() );
					}
				}
			}
			return query.substr( 1 );
		}

		protected function setQuery( q:String, d:String ):void
		{
			if ( q != null )
			{
				if ( d == null )
				{
					delete params[ q ];
				}
				else
				{
					params[ q ] = d;
				}
			}
		}

		protected function checkParams():void
		{
			for each ( var r:String in requirs )
			{
				if ( !( r in params ) )
				{
					throw new ArgumentError( callName + " 方法必须带参数: " + r );
				}
			}
		}

		public function clean():void
		{
			if ( loader )
			{
				loader.removeEventListener( Event.COMPLETE, onComplete );
				loader.removeEventListener( HTTPStatusEvent.HTTP_STATUS, onHttpStatus );
				loader.removeEventListener( IOErrorEvent.IO_ERROR, onIoError );
				loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
				loader = null;
			}
			if ( request )
			{
				request = null
			}
			if ( tryTimer && tryTimer.running )
			{
				tryTimer.stop();
				tryTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, onTryTimer );
				tryTimer = null;
			}
			calling = false;
		}

		protected function onComplete( e:Event ):void
		{
			trace( "resource: " + e.type );
			if ( completedCallback != null )
			{
				if ( response == null )
					response = new Response();
				response.load( loader.data );
				completedCallback( callName, response );
			}
			//Console.log( loader.data );
			clean();
		}

		protected function onHttpStatus( e:HTTPStatusEvent ):void
		{
			//Console.log( e.status );
		}

		protected function onIoError( e:IOErrorEvent ):void
		{
			Console.log( e.text );
			//clean();
			tryAgain();
		}

		protected function onSecurityError( e:SecurityErrorEvent ):void
		{
			Console.log( e.text );
			//clean();
			tryAgain();
		}

		/*
		 *
		 */
		protected function tryAgain():void
		{
			if ( this.host != '' && this.securitySalt != '' )
			{
				Console.log( 'try again after 5s.' );
				tryTimer = new Timer( 5 * 1000, 1 );
				tryTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onTryTimer );
				tryTimer.start();
			}
		}

		/**
		 * A meeting ID that can be used to identify this meeting by the third party application.
		 * This must be unique to the server that you are calling: different active meetings can not have the same meeting ID.
		 * If you supply a non-unique meeting ID (a meeting is already in progress with the same meeting ID), then if the other parameters in the create call are identical, the create call will succeed (but will receive a warning message in the response).
		 * The create call is idempotent: calling multiple times does not have any side effect.
		 * This enables a third party applications to avoid checking if the meeting is running and always call create before joining each user.
		 * Meeting IDs should only contain upper/lower ASCII letters, numbers, dashes, or underscores.
		 * A good choice for the meeting ID is to generate a GUID value, this all but guarantees that different meetings will not have the same meetingID.
		 */
		public function get meetingID():String
		{
			return _meetingID;
		}

		public function set meetingID( value:String ):void
		{
			_meetingID = value;
			setQuery( "meetingID", value );
		}

	}

}