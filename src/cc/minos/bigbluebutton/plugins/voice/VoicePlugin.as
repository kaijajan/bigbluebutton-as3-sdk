package cc.minos.bigbluebutton.plugins.voice
{
	import cc.minos.bigbluebutton.core.IVoiceConnection;
	import cc.minos.bigbluebutton.core.VoiceConnection;
	import cc.minos.bigbluebutton.plugins.Plugin;
	import cc.minos.utils.VersionUtil;
	import flash.media.Microphone;
	import flash.media.MicrophoneEnhancedMode;
	import flash.media.MicrophoneEnhancedOptions;
	import flash.media.SoundCodec;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class VoicePlugin extends Plugin
	{
		
		protected var voiceConnection:IVoiceConnection;
		protected var options:VoiceOptions;
		protected var mic:Microphone;
		
		public function VoicePlugin( options:VoiceOptions = null )
		{
			super();
			if ( options == null )
				options = new VoiceOptions();
			this.options = options;
			this._application = "sip";
			this._name = "[VoicePlugin]";
			this._shortcut = "voice";
		}
		
		public function join():void
		{
			setupMicrophone();
			var uname:String = encodeURIComponent( bbb.conferenceParameters.externUserID + "-bbbID-" + bbb.conferenceParameters.username );
			voiceConnection.connect( uri, bbb.conferenceParameters.internalUserID, uname , bbb.conferenceParameters.webvoiceconf ,mic);
		}
		
		public function hangup():void
		{
			voiceConnection.hangup();
		}
		
		protected function setupMicrophone():void
		{
			if ( noMicrophone() )
			{
				trace( name + " microphone not found. " );
			}
			else
			{
				mic = Microphone.getMicrophone();
				if (( VersionUtil.getFlashPlayerVersion() >= 10.3 ) && options.enabledEchoCancel )
				{
					trace( name + " Using acoustic echo cancellation." );
					mic = Microphone( Microphone[ "getEnhancedMicrophone" ]() );
					var micOptions:MicrophoneEnhancedOptions = new MicrophoneEnhancedOptions();
					micOptions.mode = MicrophoneEnhancedMode.FULL_DUPLEX;
					micOptions.autoGain = false;
					micOptions.echoPath = 128;
					micOptions.nonLinearProcessing = true;
					mic[ 'enhancedOptions' ] = micOptions;
				}
				else
				{
				}
				
				mic.setUseEchoSuppression( true );
				mic.setLoopBack( false );
				mic.setSilenceLevel( 0, 20000 );
				if ( options.codec == "SPEEX" )
				{
					mic.encodeQuality = 6;
					mic.codec = SoundCodec.SPEEX;
					mic.framesPerPacket = 1;
					mic.noiseSuppressionLevel = 0;
					mic.rate = 16;
					trace( name + " Using SPEEX whideband codec." );
				}
				else
				{
					mic.codec = SoundCodec.NELLYMOSER;
					mic.rate = 8;
					trace( "Using Nellymoser codec." );
				}
				mic.gain = 60;
			}
		}
		
		protected function noMicrophone():Boolean
		{
			return (( Microphone.getMicrophone() == null ) || ( Microphone.names.length == 0 ) || (( Microphone.names.length == 1 ) && ( Microphone.names[ 0 ] == "Unknown Microphone" ) ) );
		}
		
		override public function init():void
		{
			voiceConnection = new VoiceConnection();
		}
		
		override public function start():void
		{
			if ( options.autoJoin )
			{
				if ( options.skipCheck || noMicrophone() )
				{
					join();
				}
				else
				{
					//show miicphone settings.
				}
			}
		}
		
		override public function stop():void
		{
			voiceConnection.disconnect( true );
		}
	
	}
}