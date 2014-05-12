package cc.minos.bigbluebutton.plugins.voice
{
	import cc.minos.bigbluebutton.core.IVoiceConnection;
	import cc.minos.bigbluebutton.core.VoiceConnection;
	import cc.minos.bigbluebutton.events.ConnectionFailedEvent;
	import cc.minos.bigbluebutton.events.ConnectionSuccessEvent;
	import cc.minos.bigbluebutton.events.VoiceConferenceEvent;
	import cc.minos.bigbluebutton.events.VoiceConnectionEvent;
	import cc.minos.bigbluebutton.plugins.Plugin;
	import cc.minos.bigbluebutton.plugins.users.IUsersPlugin;
	import cc.minos.bigbluebutton.Role;
	import cc.minos.console.Console;
	import cc.minos.utils.VersionUtil;
	import flash.events.StatusEvent;
	import flash.media.Microphone;
	import flash.media.MicrophoneEnhancedMode;
	import flash.media.MicrophoneEnhancedOptions;
	import flash.media.SoundCodec;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class VoicePlugin extends Plugin implements IVoicePlugin
	{
		
		protected var voiceConnection:IVoiceConnection;
		protected var options:VoiceOptions;
		protected var mic:Microphone;
		protected var fitstJoined:Boolean = true;
		protected var onCall:Boolean = false;
		protected var rejoining:Boolean = false;
		protected var userHangup:Boolean = false;
		protected var withMic:Boolean = false;
		
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
		
		public function join( withMic:Boolean ):void
		{
			userHangup = false;
			this.withMic = withMic;
			if ( withMic )
			{
				setupMicrophone();
			}
			else
			{
				Console.log( name + " not microphone." );
			}
			var uname:String = encodeURIComponent( bbb.conferenceParameters.externUserID + "-bbbID-" + bbb.conferenceParameters.username );
			voiceConnection.connect( uri, bbb.conferenceParameters.internalUserID, uname, bbb.conferenceParameters.webvoiceconf, mic );
		}
		
		public function rejoin():void
		{
			if ( !rejoining && !userHangup )
			{
				Console.log( "rejoining voice" );
				rejoining = true;
				join( withMic );
			}
		}
		
		public function userRequestedHangup():void
		{
			userHangup = true;
			hangup();
		}
		
		public function hangup():void
		{
			if ( onCall )
			{
				voiceConnection.hangup();
				onCall = false;
			}
		}
		
		protected function setupMicrophone():void
		{
			Console.log( name + " Using acoustic echo cancellation." );
			mic = Microphone.getEnhancedMicrophone();
			var micOptions:MicrophoneEnhancedOptions = new MicrophoneEnhancedOptions();
			micOptions.mode = MicrophoneEnhancedMode.FULL_DUPLEX;
			micOptions.autoGain = false;
			micOptions.echoPath = 128;
			micOptions.nonLinearProcessing = true;
			mic.enhancedOptions = micOptions;
			mic.setUseEchoSuppression( true );
			mic.setLoopBack( false );
			mic.setSilenceLevel( 0, 20000 );
			mic.encodeQuality = 6;
			mic.codec = SoundCodec.SPEEX;
			mic.framesPerPacket = 1;
			//mic.noiseSuppressionLevel = 0;
			mic.rate = 16;
			Console.log( name + " Using SPEEX whideband codec." );
			mic.gain = 60;
		}
		
		private function onMicStatus( e:StatusEvent ):void
		{
			switch ( e.code )
			{
				case "Microphone.Muted": 
					Console.log( "Access to microphone has been denied." );
					join( false );
					break;
				case "Microphone.Unmuted": 
					Console.log( "Access to the microphone has been allowed." );
					join( true );
					break;
				default: 
					Console.log( "unknown micStatusHandler event: " + e );
			}
		}
		
		protected function noMicrophone():Boolean
		{
			return (( Microphone.getMicrophone() == null ) || ( Microphone.names.length == 0 ) || (( Microphone.names.length == 1 ) && ( Microphone.names[ 0 ] == "Unknown Microphone" ) ) );
		}
		
		override public function init():void
		{
			voiceConnection = new VoiceConnection();
			( voiceConnection as VoiceConnection ).addEventListener( ConnectionSuccessEvent.SUCCESS, onConnectionSuccess );
			( voiceConnection as VoiceConnection ).addEventListener( ConnectionFailedEvent.FAILED, onConnectionFailed );
			//
			( voiceConnection as VoiceConnection ).addEventListener( VoiceConferenceEvent.JOINED, onVoiceConference );
			( voiceConnection as VoiceConnection ).addEventListener( VoiceConferenceEvent.DISCONNECTED, onVoiceConference );
		}
		
		/**
		 *
		 * @param	e
		 */
		private function onVoiceConference( e:VoiceConferenceEvent ):void
		{
			if ( e.type == VoiceConferenceEvent.DISCONNECTED )
			{
				hangup();
				rejoin();
			}
			else if ( e.type == VoiceConferenceEvent.JOINED )
			{
				onCall = true;
				if ( fitstJoined ) {
					fitstJoined = false;	
					if ( options.muteAll )
					{
						if ( usersPlugin && usersPlugin.presenter )
						{
							Console.log( name + " muteAllUsers");
							usersPlugin.muteAllUsers( true );
						}
						else
						{
							
						}
					}
				}
				rejoining = false;
			}
		}
		
		/**
		 * Voice Connection Success
		 * @param	e
		 */
		private function onConnectionSuccess( e:ConnectionSuccessEvent ):void
		{
			var successEvent:VoiceConnectionEvent = new VoiceConnectionEvent( VoiceConnectionEvent.SUCCESS );
			dispatchRawEvent( successEvent );
		}
		
		private function onConnectionFailed( e:ConnectionFailedEvent ):void
		{
			var failedEvent:VoiceConnectionEvent = new VoiceConnectionEvent( VoiceConnectionEvent.FAILED );
			failedEvent.reason = e.reason;
			dispatchRawEvent( failedEvent );
		}
		
		override public function start():void
		{
			if ( options.autoJoin )
			{
				if ( options.skipCheck || noMicrophone() )
				{
					mic = Microphone.getMicrophone();
					if ( mic == null )
					{
						join( false );
					}
					else if ( mic.muted )
					{
						Security.showSettings( SecurityPanel.PRIVACY );
						mic.addEventListener( StatusEvent.STATUS, onMicStatus );
					}
					else
					{
						join( true );
					}
				}
				else
				{
					//show test
				}
			}
		}
		
		override public function stop():void
		{
			voiceConnection.disconnect( true );
		}
		
		protected function get usersPlugin():IUsersPlugin
		{
			return bbb.getPlugin( "users" ) as IUsersPlugin;
		}
	}
}