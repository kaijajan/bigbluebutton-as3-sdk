package cc.minos.bigbluebutton
{
	import cc.minos.bigbluebutton.apis.*;
	import cc.minos.bigbluebutton.apis.resources.*;
	import cc.minos.bigbluebutton.apis.responses.*;
	import cc.minos.bigbluebutton.core.*;
	import cc.minos.bigbluebutton.events.*;
	import cc.minos.bigbluebutton.models.*;
	import cc.minos.bigbluebutton.plugins.*;
	import cc.minos.bigbluebutton.plugins.chat.*;
	import cc.minos.bigbluebutton.plugins.present.*;
	import cc.minos.bigbluebutton.plugins.test.*;
	import cc.minos.bigbluebutton.plugins.users.*;
	import cc.minos.bigbluebutton.plugins.video.*;
	import cc.minos.bigbluebutton.plugins.voice.*;
	import cc.minos.bigbluebutton.plugins.whiteboard.*;
	import cc.minos.console.Console;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;

	/**
	 * ...
	 * @author Minos
	 */
	public class BigBlueButton extends EventDispatcher
	{
		public static const BBB_VERSION:String = "0.81";
		public static const VERSION:String = "1.00";

		protected var api:API;
		protected var bbb:IBigBlueButtonConnection;
		protected var config:IConfig;
		protected var conferenceParameters:IConferenceParameters;

		public function BigBlueButton( config:IConfig )
		{
			this.config = config;

			createAPI();
			createBBB();
			createPlugins();
		}

		protected function createAPI():void
		{
			//api
			api = new API( config.host, config.securitySalt );
			api.onAdministrationCallback = onAdministrationCallback;
			api.onMonitoringCallback = onMonitoringCallback;
			api.onRecordingCallback = onRecordingCallback;
		}

		protected function createBBB():void
		{
			//connection
			bbb = new BigBlueButtonConnection( config );
			bbb.addEventListener( BigBlueButtonEvent.USER_LOGIN, onBigBlueButton );
			bbb.addEventListener( BigBlueButtonEvent.USER_LOGOUT, onBigBlueButton );
			bbb.addEventListener( BigBlueButtonEvent.END_MEETING, onBigBlueButton );
			bbb.addEventListener( BigBlueButtonEvent.CHANGE_RECORDING_STATUS, onBigBlueButton );
		}

		protected function createPlugins():void
		{
			addTestPlugin();
			addUsersPlugin();
			addChatPlugin();
			addVoicePlugin();
			addVideoPlugin();
			addPresentPlugin();
			addWhiteboardPlugin();
		}

		protected function addTestPlugin():void
		{
			//test
			bbb.addPlugin( new TestPlugin() );
			bbb.addEventListener( PortTestEvent.PORT_TEST_SUCCESS, onPortTest );
			bbb.addEventListener( PortTestEvent.PORT_TEST_FAILED, onPortTest );
		}

		protected function addUsersPlugin():void
		{
			//users
			bbb.addPlugin( new UsersPlugin() );
			bbb.addEventListener( UsersEvent.JOINED, onUsers );
			bbb.addEventListener( UsersEvent.LEFT, onUsers );
			bbb.addEventListener( UsersEvent.RAISE_HAND, onUsers );
			bbb.addEventListener( UsersEvent.KICKED, onUsers );
			bbb.addEventListener( UsersEvent.USER_VOICE_JOINED, onUsers );
			bbb.addEventListener( UsersEvent.USER_VOICE_LEFT, onUsers );
			bbb.addEventListener( UsersEvent.USER_VOICE_LOCKED, onUsers );
			bbb.addEventListener( UsersEvent.USER_VOICE_MUTED, onUsers );
			bbb.addEventListener( UsersEvent.USER_VOICE_TALKING, onUsers );
			bbb.addEventListener( UsersEvent.USER_VIDEO_STREAM_STARTED, onUsers );
			bbb.addEventListener( UsersEvent.USER_VIDEO_STREAM_STOPED, onUsers );
			bbb.addEventListener( MadePresenterEvent.SWITCH_TO_PRESENTER_MODE, onSwitchMode );
			bbb.addEventListener( MadePresenterEvent.SWITCH_TO_VIEWER_MODE, onSwitchMode );
			bbb.addEventListener( MadePresenterEvent.PRESENTER_NAME_CHANGE, onSwitchMode );
		}

		protected function addChatPlugin():void
		{
			//chat
			bbb.addPlugin( new ChatPlugin() );
			bbb.addEventListener( ChatMessageEvent.PUBLIC_CHAT_MESSAGE, onMessage );
			bbb.addEventListener( ChatMessageEvent.PRIVATE_CHAT_MESSAGE, onMessage );
		}

		protected function addVoicePlugin():void
		{
			bbb.addPlugin( new VoicePlugin() );
			bbb.addEventListener( MicrophoneEvent.WARNING, onMicrophone );
		}

		protected function addVideoPlugin():void
		{
			//vdieo
			bbb.addPlugin( new VideoPlugin() );
			bbb.addEventListener( VideoConnectionEvent.SUCCESS, onVideoConnection );
			bbb.addEventListener( VideoConnectionEvent.FAILED, onVideoConnection );
		}

		protected function addWhiteboardPlugin():void
		{
			//whiteboard
			bbb.addPlugin( new WhiteboardPlugin() );
			bbb.addEventListener( WhiteboardDrawEvent.CHANGE_PRESENTATION, onWhiteboard );
			bbb.addEventListener( WhiteboardDrawEvent.CHANGE_PAGE, onWhiteboard );
			bbb.addEventListener( WhiteboardDrawEvent.CLEAR, onWhiteboard );
			bbb.addEventListener( WhiteboardDrawEvent.UNDO, onWhiteboard );
			bbb.addEventListener( WhiteboardDrawEvent.NEW_ANNOTATION, onWhiteboard );
		}

		protected function addPresentPlugin():void
		{
			//present
			bbb.addPlugin( new PresentPlugin() );
			bbb.addEventListener( PresentationEvent.PRESENTATION_READY, onPresentation );
			bbb.addEventListener( PresentationEvent.PRESENTATION_LOADED, onPresentation );
			bbb.addEventListener( PresentationEvent.PRESENTATION_REMOVED_EVENT, onPresentation );
			bbb.addEventListener( PresentationEvent.PRESENTATION_ADDED_EVENT, onPresentation );

			bbb.addEventListener( NavigationEvent.GOTO_PAGE, onGotoPage );

			bbb.addEventListener( CursorEvent.UPDATE_CURSOR, onCursor );
			bbb.addEventListener( MoveEvent.CUR_SLIDE_SETTING, onMove );
			bbb.addEventListener( MoveEvent.MOVE, onMove );

			bbb.addEventListener( ZoomEvent.ZOOM, onZoom );
			bbb.addEventListener( ZoomEvent.RESTORE, onZoom );
			bbb.addEventListener( ZoomEvent.RESIZE, onZoom );
			//bbb.addEventListener( ZoomEvent.MAXIMIZE, onZoom );

			bbb.addEventListener( UploadEvent.OFFICE_DOC_CONVERSION_SUCCESS, onUpload );
			bbb.addEventListener( UploadEvent.OFFICE_DOC_CONVERSION_FAILED, onUpload );
			bbb.addEventListener( UploadEvent.SUPPORTED_DOCUMENT, onUpload );
			bbb.addEventListener( UploadEvent.UNSUPPORTED_DOCUMENT, onUpload );
			bbb.addEventListener( UploadEvent.THUMBNAILS_UPDATE, onUpload );
			bbb.addEventListener( UploadEvent.PAGE_COUNT_FAILED, onUpload );
			bbb.addEventListener( UploadEvent.CONVERT_UPDATE, onUpload );
			bbb.addEventListener( UploadEvent.CLEAR_PRESENTATION, onUpload );
		}

		private function onZoom( e:ZoomEvent ):void
		{
			dispatchEvent( e );
		}

		protected function onSwitchMode( e:MadePresenterEvent ):void
		{
			dispatchEvent( e );
		}

		protected function onWhiteboard( e:WhiteboardDrawEvent ):void
		{
			dispatchEvent( e );
		}

		protected function onCursor( e:CursorEvent ):void
		{
			dispatchEvent( e );
		}

		protected function onMove( e:MoveEvent ):void
		{
			if ( !usersPlugin.presenter )
			{
				dispatchEvent( e );
			}
		}

		protected function onGotoPage( e:NavigationEvent ):void
		{
			dispatchEvent( e );
		}

		protected function onUpload( e:UploadEvent ):void
		{
			dispatchEvent( e );
		}

		protected function onPresentation( e:PresentationEvent ):void
		{
			if ( e.type == PresentationEvent.PRESENTATION_READY )
			{
				presentPlugin.loadPresentation( e.presentationName );
			}
			else if ( e.type == PresentationEvent.PRESENTATION_LOADED )
			{
			}
			dispatchEvent( e );
		}

		protected function onMessage( e:ChatMessageEvent ):void
		{
			Console.log( "bbb: a new message." );
			dispatchEvent( e );
		}

		protected function onUsers( e:UsersEvent ):void
		{
			//Console.log( e.type, e.userID );
			dispatchEvent( e );
		}

		protected function onBigBlueButton( e:BigBlueButtonEvent ):void
		{
			Console.log( "bbb: " + e.type );
			if ( e.type == BigBlueButtonEvent.USER_LOGIN )
			{
				bbb.startAllPlugin();
			}
			else if ( e.type == BigBlueButtonEvent.USER_LOGOUT || e.type == BigBlueButtonEvent.END_MEETING )
			{
				disconnect();
			}
			dispatchEvent( e );
		}

		//protected function onBigBlueButtonConnectionSuccess( e:ConnectionSuccessEvent ):void
		//{
		//trace( "bbb: connection success!" );
		//bbb.startAllPlugin();
		//dispatchEvent( e );
		//}
		//
		//protected function onBigBlueButtonConnectionFailed( e:ConnectionFailedEvent ):void
		//{
		//trace( "bbb: connection failed" );
		//}

		protected function onMicrophone( e:MicrophoneEvent ):void
		{
			dispatchEvent( e );
		}

		protected function onVideoConnection( e:VideoConnectionEvent ):void
		{
			dispatchEvent( e );
		}

		protected function onPortTest( e:PortTestEvent ):void
		{
			if ( e.type == PortTestEvent.PORT_TEST_SUCCESS )
			{
				Console.log( "success! connecting to bbb.", "[PortTest]" );
				bbb.connect( conferenceParameters );
			}
			else if ( e.type == PortTestEvent.PORT_TEST_FAILED )
			{
				Console.log( "test failed!", "[PortTest]" );
			}
		}

		public function end():void
		{
			api.end( config.meetingID, Role.MODERATOR );
		}

		public function connect():void
		{
			api.isMeetingRunning( config.meetingID );
		}

		public function disconnect():void
		{
			//remove all events
			bbb.removeEventListener( BigBlueButtonEvent.USER_LOGIN, onBigBlueButton );
			bbb.removeEventListener( BigBlueButtonEvent.USER_LOGOUT, onBigBlueButton );
			bbb.removeEventListener( BigBlueButtonEvent.END_MEETING, onBigBlueButton );
			bbb.removeEventListener( BigBlueButtonEvent.ERROR, onBigBlueButton );

			if ( bbb.hasPlugin( 'test' ) )
			{
				bbb.removeEventListener( PortTestEvent.PORT_TEST_SUCCESS, onPortTest );
				bbb.removeEventListener( PortTestEvent.PORT_TEST_FAILED, onPortTest );
			}
			if ( bbb.hasPlugin( 'users' ) )
			{
				bbb.removeEventListener( UsersEvent.JOINED, onUsers );
				bbb.removeEventListener( UsersEvent.LEFT, onUsers );
				bbb.removeEventListener( UsersEvent.RAISE_HAND, onUsers );
				bbb.removeEventListener( UsersEvent.KICKED, onUsers );
				bbb.removeEventListener( UsersEvent.USER_VOICE_JOINED, onUsers );
				bbb.removeEventListener( UsersEvent.USER_VOICE_LEFT, onUsers );
				bbb.removeEventListener( UsersEvent.USER_VOICE_LOCKED, onUsers );
				bbb.removeEventListener( UsersEvent.USER_VOICE_MUTED, onUsers );
				bbb.removeEventListener( UsersEvent.USER_VOICE_TALKING, onUsers );
				bbb.removeEventListener( UsersEvent.USER_VIDEO_STREAM_STARTED, onUsers );
				bbb.removeEventListener( UsersEvent.USER_VIDEO_STREAM_STOPED, onUsers );
				bbb.removeEventListener( MadePresenterEvent.SWITCH_TO_PRESENTER_MODE, onSwitchMode );
				bbb.removeEventListener( MadePresenterEvent.SWITCH_TO_VIEWER_MODE, onSwitchMode );
				bbb.removeEventListener( MadePresenterEvent.PRESENTER_NAME_CHANGE, onSwitchMode );
			}
			if ( bbb.hasPlugin( 'chat' ) )
			{
				bbb.removeEventListener( ChatMessageEvent.PUBLIC_CHAT_MESSAGE, onMessage );
				bbb.removeEventListener( ChatMessageEvent.PRIVATE_CHAT_MESSAGE, onMessage );
			}
			if ( bbb.hasPlugin( 'voice' ) )
			{
				bbb.removeEventListener( MicrophoneEvent.WARNING, onMicrophone );
			}
			if ( bbb.hasPlugin( 'video' ) )
			{
				bbb.removeEventListener( VideoConnectionEvent.SUCCESS, onVideoConnection );
				bbb.removeEventListener( VideoConnectionEvent.FAILED, onVideoConnection );
			}
			if ( bbb.hasPlugin( 'whiteboard' ) )
			{
				bbb.removeEventListener( WhiteboardDrawEvent.CHANGE_PRESENTATION, onWhiteboard );
				bbb.removeEventListener( WhiteboardDrawEvent.CHANGE_PAGE, onWhiteboard );
				bbb.removeEventListener( WhiteboardDrawEvent.CLEAR, onWhiteboard );
				bbb.removeEventListener( WhiteboardDrawEvent.UNDO, onWhiteboard );
				bbb.removeEventListener( WhiteboardDrawEvent.NEW_ANNOTATION, onWhiteboard );
			}
			if ( bbb.hasPlugin( 'present' ) )
			{
				bbb.removeEventListener( PresentationEvent.PRESENTATION_READY, onPresentation );
				bbb.removeEventListener( PresentationEvent.PRESENTATION_LOADED, onPresentation );
				bbb.removeEventListener( PresentationEvent.PRESENTATION_REMOVED_EVENT, onPresentation );
				bbb.removeEventListener( PresentationEvent.PRESENTATION_ADDED_EVENT, onPresentation );
				bbb.removeEventListener( NavigationEvent.GOTO_PAGE, onGotoPage );
				bbb.removeEventListener( CursorEvent.UPDATE_CURSOR, onCursor );
				bbb.removeEventListener( MoveEvent.CUR_SLIDE_SETTING, onMove );
				bbb.removeEventListener( MoveEvent.MOVE, onMove );
				bbb.removeEventListener( ZoomEvent.ZOOM, onZoom );
				bbb.removeEventListener( ZoomEvent.RESTORE, onZoom );
				bbb.removeEventListener( ZoomEvent.RESIZE, onZoom );
				//bbb.addEventListener( ZoomEvent.MAXIMIZE, onZoom );
				bbb.removeEventListener( UploadEvent.OFFICE_DOC_CONVERSION_SUCCESS, onUpload );
				bbb.removeEventListener( UploadEvent.OFFICE_DOC_CONVERSION_FAILED, onUpload );
				bbb.removeEventListener( UploadEvent.SUPPORTED_DOCUMENT, onUpload );
				bbb.removeEventListener( UploadEvent.UNSUPPORTED_DOCUMENT, onUpload );
				bbb.removeEventListener( UploadEvent.THUMBNAILS_UPDATE, onUpload );
				bbb.removeEventListener( UploadEvent.PAGE_COUNT_FAILED, onUpload );
				bbb.removeEventListener( UploadEvent.CONVERT_UPDATE, onUpload );
				bbb.removeEventListener( UploadEvent.CLEAR_PRESENTATION, onUpload );
			}
			//clear all plugin
			bbb.disconnect( true );
		}

		protected function onAdministrationCallback( callName:String, response:Response ):void
		{
			if ( response.returncode == "SUCCESS" )
			{
				switch ( callName )
				{
					case CreateResource.CALL_NAME:
						api.join( config.username, config.meetingID, config.role );
						break;
					case EnterResource.CALL_NAME:

						var res:JoinResponse = JoinResponse( response );
						conferenceParameters = new ConferenceParameters();
						conferenceParameters.conference = res.conference;
						conferenceParameters.meetingName = res.meetingID;
						conferenceParameters.externMeetingID = res.externMeetingID;
						conferenceParameters.room = res.room;

						conferenceParameters.externUserID = res.externUserID;
						conferenceParameters.internalUserID = res.internalUserID;
						conferenceParameters.username = res.fullname;
						conferenceParameters.role = res.role;

						conferenceParameters.voicebridge = res.voicebridge;
						conferenceParameters.webvoiceconf = res.webvoiceconf;

						conferenceParameters.welcome = res.welcome;
						conferenceParameters.record = res.record;

						if ( testPlugin != null )
						{
							testPlugin.test();
						}
						else
						{
							bbb.connect( conferenceParameters );
						}

						break;
					default:
					//trace( response.data );
				}
			}
			else
			{
				Console.log( "error: " + response.message );
			}
		}

		protected function onMonitoringCallback( callName:String, response:Response ):void
		{
			if ( response.returncode == "SUCCESS" )
			{
				if ( RunningResponse( response ).running )
				{
					api.join( config.username, config.meetingID, config.role );
				}
				else if ( config.role == Role.MODERATOR )
				{
					var meta:String = "description:record;email:" + config.username + ";title:" + config.meetingID + "";
					var voiceBridge:String = Math.floor( 70000 + 9999 * Math.random() ).toString();
					api.create( config.meetingID, config.meetingID, Role.VIEWER, Role.MODERATOR, "welcome", null, voiceBridge, null, null, config.record, 0, meta );
				}
				else
				{
					Console.log( "api: not meeting running." );
					sendErrorEvent({ type: "Error", message: "bbb.meeting.closed" } );
				}

			}
			else
			{
				//FAILED
				sendErrorEvent({ message: response.message, type: "Error" } );
			}
		}

		protected function onRecordingCallback( callName:String, response:Response ):void
		{
			//<!- -!>
		}

		protected function sendErrorEvent( data:Object = null ):void
		{
			var errorEvent:BigBlueButtonEvent = new BigBlueButtonEvent( BigBlueButtonEvent.ERROR );
			errorEvent.data = data;
			dispatchEvent( errorEvent );
		}

		/* upload file */

		protected var file:FileReference;
		protected var uploading:Boolean = false;

		public function browse():void
		{
			if ( uploading )
			{
				Console.log( "bbb: uploading other file, please try again late" );
				return;
			}
			file = new FileReference();
			file.addEventListener( Event.SELECT, onSelect );
			file.addEventListener( Event.CANCEL, onCancel );
			file.browse([ new FileFilter( "演示文件", "*.pdf;*.doc;*.docx;*.xls;*.xlsx;*.ppt;*.pptx;*.txt;*.rtf;*.odt;*.ods;*.odp;*.odg;*.odc;*.odi;*.jpg;*.png" ), new FileFilter( "pdf", "*.pdf" ), new FileFilter( "word", "*.doc;*.docx;*.odt;*.rtf;*.txt" ), new FileFilter( "excel", "*.xls;*.xlsx;*.ods" ), new FileFilter( "powerpoint", "*.ppt;*.pptx;*.odp" ), new FileFilter( "image", "*.jpg;*.jpeg;*.png" ) ] );
		}

		protected function onCancel( e:Event ):void
		{
			file.removeEventListener( Event.SELECT, onSelect );
			file.removeEventListener( Event.CANCEL, onCancel );
			file = null
		}

		protected function onSelect( e:Event ):void
		{
			uploading = true;
			file.addEventListener( Event.COMPLETE, onComplete );
			file.addEventListener( ProgressEvent.PROGRESS, onProgress );
			file.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			file.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
			presentPlugin.upload( file );
		}

		private function onIOError(e:IOErrorEvent):void
		{
			uploading = false;
			Console.log( 'bbb: upload io error ' + e.text );
		}

		private function onSecurityError(e:SecurityErrorEvent):void
		{
			uploading = false;
			Console.log( 'bbb: upload security error ' + e.text );
		}

		protected function onComplete( e:Event ):void
		{
			uploading = false;
			Console.log( "bbb: upload completed!" );
		}

		protected function onProgress( e:ProgressEvent ):void
		{
			Console.log( "bbb: upload " + Number(( e.bytesLoaded / e.bytesTotal ).toFixed( 2 ) ) * 100 + "%" );
		}

		/* */

		public function get videoPlugin():IVideoPlugin
		{
			return bbb.getPlugin( "video" ) as IVideoPlugin;
		}

		public function get voicePlugin():IVoicePlugin
		{
			return bbb.getPlugin( "voice" ) as IVoicePlugin;
		}

		public function get testPlugin():ITestPlugin
		{
			return bbb.getPlugin( "test" ) as ITestPlugin;
		}

		public function get usersPlugin():IUsersPlugin
		{
			return bbb.getPlugin( "users" ) as IUsersPlugin;
		}

		public function get chatPlugin():IChatPlugin
		{
			return bbb.getPlugin( "chat" ) as IChatPlugin;
		}

		public function get presentPlugin():IPresentPlugin
		{
			return bbb.getPlugin( "present" ) as IPresentPlugin;
		}

		public function get whiteboardPlugin():IWhiteboardPlugin
		{
			return bbb.getPlugin( "whiteboard" ) as IWhiteboardPlugin;
		}
	}

}