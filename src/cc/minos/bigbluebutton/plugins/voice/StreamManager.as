package cc.minos.bigbluebutton.plugins.voice
{
	import cc.minos.utils.VersionUtil;
	import flash.events.ActivityEvent;
	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.media.Microphone;
	import flash.media.MicrophoneEnhancedMode;
	import flash.media.MicrophoneEnhancedOptions;
	import flash.media.SoundCodec;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Capabilities;
	
	public class StreamManager extends EventDispatcher
	{
		public var connection:NetConnection = null;
		private var incomingStream:NetStream = null
		private var outgoingStream:NetStream = null;
		private var publishName:String = null;
		private var mic:Microphone = null;
		private var isCallConnected:Boolean = false;
		private var muted:Boolean = false;
		private var audioCodec:String = "SPEEX";
		
		public function StreamManager()
		{
		}
		
		public function setConnection( connection:NetConnection ):void
		{
			this.connection = connection;
		}
		
		public function initMicrophone( enabledEchoCancel:Boolean = true ):void
		{
			mic = Microphone.getMicrophone( -1 );
			if ( mic == null )
			{
				initWithNoMicrophone();
			}
			else
			{
				setupMicrophone( enabledEchoCancel );
				mic.addEventListener( StatusEvent.STATUS, micStatusHandler );
			}
		}
		
		private function setupMicrophone( enabledEchoCancel:Boolean = true ):void
		{
			if (( VersionUtil.getFlashPlayerVersion() >= 10.3 ) && enabledEchoCancel )
			{
				trace( "Using acoustic echo cancellation." );
				mic = Microphone( Microphone[ "getEnhancedMicrophone" ]() );
				var options:MicrophoneEnhancedOptions = new MicrophoneEnhancedOptions();
				options.mode = MicrophoneEnhancedMode.FULL_DUPLEX;
				options.autoGain = false;
				options.echoPath = 128;
				options.nonLinearProcessing = true;
				mic[ 'enhancedOptions' ] = options;
			}
			else
			{
			}
			
			mic.setUseEchoSuppression( true );
			mic.setLoopBack( false );
			mic.setSilenceLevel( 0, 20000 );
			if ( audioCodec == "SPEEX" )
			{
				mic.encodeQuality = 6;
				mic.codec = SoundCodec.SPEEX;
				mic.framesPerPacket = 1;
				mic.noiseSuppressionLevel = 0;
				mic.rate = 16;
				trace( "Using SPEEX whideband codec." );
			}
			else
			{
				mic.codec = SoundCodec.NELLYMOSER;
				mic.rate = 8;
				trace( "Using Nellymoser codec." );
			}
			mic.gain = 60;
		}
		
		public function initWithNoMicrophone():void
		{
			dispatchEvent( new MicrophoneEvent( MicrophoneEvent.MICROPHONE_UNAVAIL_EVENT ) );
		}
		
		private function micStatusHandler( event:StatusEvent ):void
		{
			switch ( event.code )
			{
				case "Microphone.Muted": 
					dispatchEvent( new MicrophoneEvent( MicrophoneEvent.MIC_ACCESS_DENIED_EVENT ) );
					break;
				case "Microphone.Unmuted": 
					dispatchEvent( new MicrophoneEvent( MicrophoneEvent.MIC_ACCESS_ALLOWED_EVENT ) );
					break;
				default: 
					trace( "unknown micStatusHandler event: " + event );
			}
		}
		
		public function callConnected( playStreamName:String, publishStreamName:String, codec:String ):void
		{
			isCallConnected = true;
			audioCodec = codec;
			setupIncomingStream();
			
			if ( mic != null )
			{
				setupOutgoingStream();
			}
			
			setupPlayStatusHandler();
			play( playStreamName );
			publish( publishStreamName );
		}
		
		private function play( playStreamName:String ):void
		{
			incomingStream.play( playStreamName );
		}
		
		private function publish( publishStreamName:String ):void
		{
			if ( mic != null )
				outgoingStream.publish( publishStreamName, "live" );
			else
				trace( "SM publish: No Microphone to publish" );
		}
		
		private function setupIncomingStream():void
		{
			incomingStream = new NetStream( connection );
			incomingStream.addEventListener( NetStatusEvent.NET_STATUS, netStatus );
			incomingStream.addEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler );
			/*
			 * Set the bufferTime to 0 (zero) for live stream as suggested in the doc.
			 * http://help.adobe.com/en_US/FlashPlatform/beta/reference/actionscript/3/flash/net/NetStream.html#bufferTime
			 * If we don't, we'll have a long audio delay when a momentary network congestion occurs. When the congestion
			 * disappears, a flood of audio packets will arrive at the client and Flash will buffer them all and play them.
			 * http://stackoverflow.com/questions/1079935/actionscript-netstream-stutters-after-buffering
			 * ralam (Dec 13, 2010)
			 */
			incomingStream.bufferTime = 0;
			incomingStream.receiveAudio( true );
			incomingStream.receiveVideo( false );
		}
		
		private function setupOutgoingStream():void
		{
			outgoingStream = new NetStream( connection );
			outgoingStream.addEventListener( NetStatusEvent.NET_STATUS, netStatus );
			outgoingStream.addEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler );
			setupMicrophone();
			outgoingStream.attachAudio( mic );
		}
		
		private function setupPlayStatusHandler():void
		{
			var custom_obj:Object = new Object();
			custom_obj.onPlayStatus = playStatus;
			custom_obj.onMetadata = onMetadata;
			incomingStream.client = custom_obj;
			if ( mic != null )
				outgoingStream.client = custom_obj;
		}
		
		public function stopStreams():void
		{
			trace( "Stopping Stream(s)" );
			if ( incomingStream != null )
			{
				trace( "--Stopping Incoming Stream" );
				incomingStream.play( false );
			}
			else
			{
				trace( "--Incoming Stream Null" );
			}
			
			if ( outgoingStream != null )
			{
				trace( "--Stopping Outgoing Stream" );
				outgoingStream.attachAudio( null );
				outgoingStream.close();
			}
			else
			{
				trace( "--Outgoing Stream Null" );
			}
			
			isCallConnected = false;
			trace( "Stopped Stream(s)" );
		}
		
		private function netStatus( evt:NetStatusEvent ):void
		{
			var event:PlayStreamStatusEvent = new PlayStreamStatusEvent();
			trace( "******* evt.info.code  " + evt.info.code );
			switch ( evt.info.code )
			{
				case "NetStream.Play.StreamNotFound": 
					event.status = PlayStreamStatusEvent.PLAY_STREAM_STATUS_EVENT;
					break;
				case "NetStream.Play.Failed": 
					event.status = PlayStreamStatusEvent.FAILED;
					break;
				case "NetStream.Play.Start": 
					event.status = PlayStreamStatusEvent.START;
					break;
				case "NetStream.Play.Stop": 
					event.status = PlayStreamStatusEvent.STOP;
					break;
				case "NetStream.Buffer.Full": 
					event.status = PlayStreamStatusEvent.BUFFER_FULL;
					break;
				default: 
			}
			dispatchEvent( event );
		}
		
		private function asyncErrorHandler( event:AsyncErrorEvent ):void
		{
			trace( "AsyncErrorEvent: " + event );
		}
		
		private function playStatus( event:Object ):void
		{
			// do nothing
		}
		
		private function onMetadata( event:Object ):void
		{
			trace( "Recieve ON METADATA from SIP" );
		}
		
	}
}