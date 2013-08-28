package cc.minos.bigbluebutton.plugins
{
	import cc.minos.bigbluebutton.plugins.present.*;
	import cc.minos.bigbluebutton.plugins.present.events.PresentationEvent;
	import cc.minos.utils.ArrayUtil;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class PresentPlugin extends Plugin
	{
		private var service:PresentationService;
		private var soService:PresentSOService;
		private var uploadService:FileUploadService;
		private var host:String;
		private var conference:String;
		private var room:String;
		
		public var presentationNames:Array;
		public var slides:Array;
		
		public function PresentPlugin()
		{
			super();
			this.name = "[PresentPlugin]";
			this.shortcut = "present";
		}
		
		override public function init():void
		{
			host = "http://" + bbb.conferenceParameters.host;
			conference = bbb.conferenceParameters.conference;
			room = bbb.conferenceParameters.room;
			
			presentationNames = [];
			slides = [];
			soService = new PresentSOService( this );
			service = new PresentationService();
			service.addCompleteListener( onPresentationDataCompleted );
			uploadService = new FileUploadService( this, host + "/bigbluebutton/presentation/upload", conference, room );
		}
		
		private function onPresentationDataCompleted( presentationName:String, slides:Array ):void
		{
			if ( slides.length > 0 )
			{
				trace( 'presentation has been loaded  presentationName=' + presentationName );
				updatePresentationNames( presentationName );
				
				var loadedEvent:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_LOADED );
				loadedEvent.presentationName = presentationName;
				loadedEvent.slides = slides;
				dispatchEvent( loadedEvent );
				
				if ( presenter )
				{
					//sharePresentation( true , presentationName );
					//soService.clearPresentation();
				}
				else
				{
					//load current slide
					
				}
				loadCurrentSlideLocally();
			}
			else
			{
				trace( 'failed to load presentation' );
			}
		}
		
		public function updatePresentationNames( presentationName:String ):void {
			if( !ArrayUtil.containsValue( presentationNames, presentationName ) )
					presentationNames.push( presentationName );
		}
		
		public function get userID():String
		{
			return bbb.plugins[ 'users' ].getMe().userID;
		}
		
		public function get presenter():Boolean
		{
			return bbb.plugins[ 'users' ].getMe().presenter;
		}
		
		override public function get uri():String
		{
			var _uri:String = super.uri + "/" + bbb.conferenceParameters.room;
			return _uri;
		}
		
		override public function start():void
		{
			soService.connect();
		}
		
		override public function stop():void
		{
			soService.disconnect();
		}
		
		public function startUpload( presentationName:String, file:FileReference ):void
		{
			var fileSize:Number = file.size;
			var maxFileSize:Number = 30000000;
			
			if ( fileSize > maxFileSize )
			{
				trace( "File exceeds max limit:(" + fileSize + ">" + maxFileSize + ")" );
			}
			else
			{
				trace( "Uploading file : " + presentationName );
				var filenamePattern:RegExp = /(.+)(\..+)/i;
				presentationName = presentationName.replace( filenamePattern, "$1" )
				trace( "Uploadling presentation name: " + presentationName );
				uploadService.upload( presentationName, file );
			}
		
		}
		
		public function gotoSlide( slideNumber:Number ):void
		{
			soService.gotoSlide( slideNumber );
		}
		
		public function loadCurrentSlideLocally():void
		{
			soService.getCurrentSlideNumber();
		}
		
		public function resetZoom():void
		{
			soService.restore();
		}
		
		public function loadPresentation( presentationName:String ):void
		{
			var fullUri:String = host + "/bigbluebutton/presentation/" + conference + "/" + room + "/" + presentationName + "/slides";
			fullUri = encodeURI( fullUri );
			var slideUri:String = host + "/bigbluebutton/presentation/" + conference + "/" + room + "/" + presentationName;
			slideUri = encodeURI( slideUri );
			
			//trace( "PresentationApplication::loadPresentation()... " + fullUri );
			service.load( fullUri, slides, slideUri );
			//trace( 'number of slides=' + slides.length );
		}
		
		public function sharePresentation( share:Boolean, presentationName:String ):void
		{
			soService.sharePresentation( share, presentationName );
			var timer:Timer = new Timer( 3000, 1 );
			timer.addEventListener( TimerEvent.TIMER, sendViewerNotify );
			timer.start();
		}
		
		public function removePresentation( presentationName:String ):void
		{
			if ( presentationName != null && presentationName != "" )
				soService.removePresentation( presentationName );
		}
		
		private function sendViewerNotify( e:TimerEvent ):void
		{
			soService.gotoSlide( 0 );
		}
		
		public function moveSlide( xOffset:Number, yOffset:Number, slideToCanvasWidthRatio:Number, slideToCanvasHeightRatio:Number ):void
		{
			soService.move( xOffset, yOffset, slideToCanvasWidthRatio, slideToCanvasHeightRatio );
		}
		
		public function zoomSlide( xOffset:Number, yOffset:Number, slideToCanvasWidthRatio:Number, slideToCanvasHeightRatio:Number ):void
		{
			soService.zoom( xOffset, yOffset, slideToCanvasWidthRatio, slideToCanvasHeightRatio );
		}
		
		public function sendCursorUpdate( xPercent:Number, yPercent:Number ):void
		{
			soService.sendCursorUpdate( xPercent, yPercent );
		}
		
		public function resizeSlide( newSizeInPercent:Number ):void
		{
			soService.resizeSlide( newSizeInPercent );
		}
	}

}