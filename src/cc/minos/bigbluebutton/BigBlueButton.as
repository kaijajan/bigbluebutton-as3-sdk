package cc.minos.bigbluebutton
{
	import cc.minos.bigbluebutton.apis.*;
	import cc.minos.bigbluebutton.apis.resources.*;
	import cc.minos.bigbluebutton.apis.responses.*;
	import cc.minos.bigbluebutton.core.*;
	import cc.minos.bigbluebutton.events.*;
	import cc.minos.bigbluebutton.models.*;
	import cc.minos.bigbluebutton.plugins.*;
	import cc.minos.bigbluebutton.plugins.chat.ChatPlugin;
	import cc.minos.bigbluebutton.plugins.chat.IChatPlugin;
	import cc.minos.bigbluebutton.plugins.present.IPresentPlugin;
	import cc.minos.bigbluebutton.plugins.present.PresentPlugin;
	import cc.minos.bigbluebutton.plugins.test.TestPlugin;
	import cc.minos.bigbluebutton.plugins.users.IUsersPlugin;
	import cc.minos.bigbluebutton.plugins.users.UsersPlugin;
	import cc.minos.bigbluebutton.plugins.video.VideoPlugin;
	import cc.minos.bigbluebutton.plugins.voice.VoicePlugin;
	import cc.minos.bigbluebutton.plugins.whiteboard.IWhiteboardPlugin;
	import cc.minos.bigbluebutton.plugins.whiteboard.WhiteboardPlugin;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class BigBlueButton extends EventDispatcher
	{
		public static const version:String = "1.00";
		
		protected var api:API;
		protected var bbb:IBigBlueButtonConnection;
		protected var config:IConfig;
		protected var conferenceParameters:IConferenceParameters;
		
		public function BigBlueButton( config:IConfig )
		{
			this.config = config;
			
			api = new API( config.host, config.securitySalt );
			api.onAdministrationCallback = onAdministrationCallback;
			api.onMonitoringCallback = onMonitoringCallback;
			api.onRecordingCallback = onRecordingCallback;
			
			bbb = new BigBlueButtonConnection( config );
			bbb.addEventListener( ConnectionSuccessEvent.SUCCESS, onBigBlueButtonConnectionSuccess );
			
			bbb.addPlugin( new TestPlugin() );
			bbb.addEventListener( PortTestEvent.PORT_TEST_SUCCESS, onPortTest );
			bbb.addEventListener( PortTestEvent.PORT_TEST_FAILED, onPortTest );
			
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
			
			bbb.addPlugin( new ChatPlugin() );
			bbb.addEventListener( ChatMessageEvent.PUBLIC_CHAT_MESSAGE, onMessage );
			bbb.addEventListener( ChatMessageEvent.PRIVATE_CHAT_MESSAGE, onMessage );
			
			bbb.addPlugin( new VoicePlugin() );
			
			//vdieo
			bbb.addPlugin( new VideoPlugin() );
			
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
			
			bbb.addEventListener( UploadEvent.OFFICE_DOC_CONVERSION_SUCCESS, onUpload );
			bbb.addEventListener( UploadEvent.OFFICE_DOC_CONVERSION_FAILED, onUpload );
			bbb.addEventListener( UploadEvent.SUPPORTED_DOCUMENT, onUpload );
			bbb.addEventListener( UploadEvent.UNSUPPORTED_DOCUMENT, onUpload );
			bbb.addEventListener( UploadEvent.THUMBNAILS_UPDATE, onUpload );
			bbb.addEventListener( UploadEvent.PAGE_COUNT_FAILED, onUpload );
			bbb.addEventListener( UploadEvent.CONVERT_UPDATE, onUpload );
			bbb.addEventListener( UploadEvent.CLEAR_PRESENTATION, onUpload );
			
			bbb.addPlugin( new WhiteboardPlugin() );
			bbb.addEventListener( WhiteboardDrawEvent.CHANGE_PRESENTATION, onWhiteboard );
			bbb.addEventListener( WhiteboardDrawEvent.CHANGE_PAGE, onWhiteboard );
			bbb.addEventListener( WhiteboardDrawEvent.CLEAR, onWhiteboard );
			bbb.addEventListener( WhiteboardDrawEvent.UNDO, onWhiteboard );
			bbb.addEventListener( WhiteboardDrawEvent.NEW_ANNOTATION, onWhiteboard );
		}
		
		private function onSwitchMode(e:MadePresenterEvent):void 
		{
			dispatchEvent(e);
		}
		
		private function onWhiteboard( e:WhiteboardDrawEvent ):void
		{
			dispatchEvent(e);
		}
		
		private function onCursor( e:CursorEvent ):void
		{
			dispatchEvent(e);
		}
		
		private function onMove( e:MoveEvent ):void
		{
			if ( !usersPlugin.presenter )
			{
				dispatchEvent( e );
			}
		}
		
		private function onGotoPage( e:NavigationEvent ):void
		{
			dispatchEvent( e );
		}
		
		private function onUpload( e:UploadEvent ):void
		{
			//trace( e.presentationName, e.type );
		}
		
		private function onPresentation( e:PresentationEvent ):void
		{
			if ( e.type == PresentationEvent.PRESENTATION_READY )
			{
				presentPlugin.loadPresentation( e.presentationName );
			}
			else if ( e.type == PresentationEvent.PRESENTATION_LOADED )
			{
				dispatchEvent( e );
			}
		}
		
		private function onMessage( e:ChatMessageEvent ):void
		{
		}
		
		private function onUsers( e:UsersEvent ):void
		{
			trace( e.type, e.userID );
		}
		
		private function onBigBlueButtonConnectionSuccess( e:ConnectionSuccessEvent ):void
		{
			bbb.getPlugin( "users" ).start();
			bbb.getPlugin( "chat" ).start();
			bbb.getPlugin( "voice" ).start();
			bbb.getPlugin( "video" ).start();
			bbb.getPlugin( "present" ).start();
			bbb.getPlugin("whiteboard").start();
		}
		
		private function onPortTest( e:PortTestEvent ):void
		{
			if ( e.type == PortTestEvent.PORT_TEST_SUCCESS )
			{
				trace( "[PortTest] success! connecting to bbb " );
				bbb.connect( conferenceParameters );
			}
			else if ( e.type == PortTestEvent.PORT_TEST_FAILED )
			{
				trace( "[PortTest] test failed!" );
			}
		}
		
		public function connect():void
		{
			api.isMeetingRunning( config.meetingID );
		}
		
		public function disconnect():void
		{
			bbb.disconnect( true );
		}
		
		private function onAdministrationCallback( callName:String, response:Response ):void
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
						
						if ( bbb.hasPlugin( "test" ) )
						{
							bbb.getPlugin( "test" ).start();
						}
						else
						{
							bbb.connect( conferenceParameters );
						}
						
						break;
					default: 
				}
			}
			else
			{
				trace( "api: create meeting error." );
			}
		}
		
		private function onMonitoringCallback( callName:String, response:Response ):void
		{
			if ( response.returncode == "SUCCESS" )
			{
				if ( RunningResponse( response ).running )
				{
					api.join( config.username, config.meetingID, config.role );
				}
				else if ( config.role == Role.MODERATOR )
				{
					api.create( config.meetingID, config.meetingID, Role.VIEWER, Role.MODERATOR, "welcome" );
				}
				else
				{
					trace( "api: not meeting running." );
				}
				
			}
		}
		
		private function onRecordingCallback( callName:String, response:Response ):void
		{
			//TODO
		}
		
		private var file:FileReference;
		private var uploading:Boolean = false;
		
		public function browse():void
		{
			if ( uploading )
			{
				trace( "uploading other file, please try again late" );
				return;
			}
			file = new FileReference();
			file.addEventListener( Event.SELECT, onSelect );
			file.addEventListener( Event.CANCEL, onCancel );
			file.browse([ new FileFilter( "演示文件", "*.pdf;*.doc;*.docx;*.xls;*.xlsx;*.ppt;*.pptx;*.txt;*.rtf;*.odt;*.ods;*.odp;*.odg;*.odc;*.odi;*.jpg;*.png" ), new FileFilter( "pdf", "*.pdf" ), new FileFilter( "word", "*.doc;*.docx;*.odt;*.rtf;*.txt" ), new FileFilter( "excel", "*.xls;*.xlsx;*.ods" ), new FileFilter( "powerpoint", "*.ppt;*.pptx;*.odp" ), new FileFilter( "image", "*.jpg;*.jpeg;*.png" ) ] );
		}
		
		private function onCancel( e:Event ):void
		{
			file.removeEventListener( Event.SELECT, onSelect );
			file.removeEventListener( Event.CANCEL, onCancel );
			file = null
		}
		
		private function onSelect( e:Event ):void
		{
			uploading = true;
			file.addEventListener( Event.COMPLETE, onComplete );
			file.addEventListener( ProgressEvent.PROGRESS, onProgress );
			IPresentPlugin( bbb.getPlugin( "present" ) ).upload( file );
		}
		
		private function onComplete( e:Event ):void
		{
			uploading = false;
			trace( "upload completed!" );
		}
		
		private function onProgress( e:ProgressEvent ):void
		{
			trace( "upload " + Number(( e.bytesLoaded / e.bytesTotal ).toFixed( 2 ) ) * 100 + "%" );
		}
		
		/** */
		
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