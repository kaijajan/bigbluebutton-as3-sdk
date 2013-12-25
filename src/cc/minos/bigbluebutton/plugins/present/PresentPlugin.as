package cc.minos.bigbluebutton.plugins.present
{
	import cc.minos.bigbluebutton.core.IMessageListener;
	import cc.minos.bigbluebutton.events.*;
	import cc.minos.bigbluebutton.plugins.Plugin;
	import cc.minos.utils.ArrayUtil;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.net.Responder;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class PresentPlugin extends Plugin implements IMessageListener, IPresentSOServiceClient, IPresentPlugin
	{
		/** 轉換成功 */
		private static const OFFICE_DOC_CONVERSION_SUCCESS_KEY:String = "OFFICE_DOC_CONVERSION_SUCCESS";
		/** 轉換失敗 */
		private static const OFFICE_DOC_CONVERSION_FAILED_KEY:String = "OFFICE_DOC_CONVERSION_FAILED";
		/** 支持轉換 */
		private static const SUPPORTED_DOCUMENT_KEY:String = "SUPPORTED_DOCUMENT";
		/** 不支持轉換 */
		private static const UNSUPPORTED_DOCUMENT_KEY:String = "UNSUPPORTED_DOCUMENT";
		/** 頁面統計失敗 */
		private static const PAGE_COUNT_FAILED_KEY:String = "PAGE_COUNT_FAILED";
		/** */
		private static const PAGE_COUNT_EXCEEDED_KEY:String = "PAGE_COUNT_EXCEEDED";
		/** 轉換頁面 */
		private static const GENERATED_SLIDE_KEY:String = "GENERATED_SLIDE";
		/** 正在生成縮略圖 */
		private static const GENERATING_THUMBNAIL_KEY:String = "GENERATING_THUMBNAIL";
		/** 成縮略圖完成 */
		private static const GENERATED_THUMBNAIL_KEY:String = "GENERATED_THUMBNAIL";
		/** 轉換完成 */
		private static const CONVERSION_COMPLETED_KEY:String = "CONVERSION_COMPLETED";
		
		/** 發送鼠標坐標 */
		private static const SEND_CURSOR_UPDATE:String = "presentation.sendCursorUpdate";
		/** 重置或移動頁面 */
		private static const RESIZE_AND_MOVE_SLIDE:String = "presentation.resizeAndMoveSlide";
		/** 移除文檔 */
		private static const REMOVE_PRESENTATION:String = "presentation.removePresentation";
		/** 獲取文檔信息 */
		private static const GET_PRESENTATION_INFO:String = "presentation.getPresentationInfo";
		/** 跳轉 */
		private static const GOTO_SLIDE:String = "presentation.gotoSlide";
		/** 共享文檔 */
		private static const SHARE_PRESENTATION:String = "presentation.sharePresentation";
		/** 演講 */
		private static const PRESENTER:String = "presenter";
		/** */
		private static const SHARING:String = "sharing";
		/** */
		private static const UPDATE_MESSAGE:String = "updateMessage";
		/** 當前頁面 */
		private static const CURRENT_PAGE:String = "currentPage";
		
		private var presentationNames:Array;
		//private var slides:Array;
		
		private var presentSO:PresentSOService;
		private var uploadService:FileUploadService;
		private var loader:PresentationLoader;
		private var currentSlide:Number = -1;
		
		private var host:String;
		private var conference:String;
		private var room:String;
		
		private var presenterViewedRegionX:Number = 0;
		private var presenterViewedRegionY:Number = 0;
		private var presenterViewedRegionW:Number = 100;
		private var presenterViewedRegionH:Number = 100;
		
		private var _currentPresentation:String;
		private var _currentPageNumber:int = 0;
		
		public function PresentPlugin()
		{
			super();
			this._name = "[PresentPlugin]";
			this._shortcut = "present";
		}
		
		override public function init():void
		{
			presentationNames = [];
			//slides = [];
			
			presentSO = new PresentSOService( this );
			loader = new PresentationLoader( onPresentationCompleted );
			uploadService = new FileUploadService();
			
			bbb.addEventListener( PresentationEvent.PRESENTATION_ADDED_EVENT, onPresentation );
			bbb.addEventListener( PresentationEvent.PRESENTATION_REMOVED_EVENT, onPresentation );
			bbb.addEventListener( PresentationEvent.PRESENTATION_READY, onPresentation );
		}
		
		private function onPresentation( e:PresentationEvent ):void
		{
			if ( e.type == PresentationEvent.PRESENTATION_ADDED_EVENT || e.type == PresentationEvent.PRESENTATION_READY )
			{
				if ( !ArrayUtil.containsValue( presentationNames, e.presentationName ) )
					presentationNames.push( e.presentationName );
			}
			else if ( e.type == PresentationEvent.PRESENTATION_REMOVED_EVENT )
			{
				ArrayUtil.removeValue( presentationNames, e.presentationName );
			}
		}
		
		override public function start():void
		{
			host = "http://" + bbb.config.host;
			conference = bbb.conferenceParameters.conference;
			room = bbb.conferenceParameters.room;
			
			bbb.addMessageListener( this );
			presentSO.connect( connection, uri );
			
			bbb.send( GET_PRESENTATION_INFO, new Responder( onGetPresentationInfo ) );
			presentSO.queryPresenterForSlideInfo( userID );
		}
		
		override public function stop():void
		{
			bbb.removeMessageListener( this );
			presentSO.disconnect();
		}
		
		override public function get uri():String
		{
			return super.uri + "/" + bbb.conferenceParameters.room;
		}
		
		private function onPresentationCompleted( presentationName:String, slides:Array ):void
		{
			if ( slides.length > 0 )
			{
				if ( presentationName == _currentPresentation )
					return;
				
				_currentPresentation = presentationName;
				_currentPageNumber = slides.length;
				
				trace( name + " loaded " + presentationName, slides.length );
				
				var loadedEvent:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_LOADED );
				loadedEvent.presentationName = presentationName;
				loadedEvent.slides = slides;
				dispatchRawEvent( loadedEvent );
				
				if ( presenter )
				{
					sharePresentation( presentationName, true );
				}
				else
				{
					if ( currentSlide >= 0 )
					{
						var e:NavigationEvent = new NavigationEvent( NavigationEvent.GOTO_PAGE )
						e.pageNumber = currentSlide;
						dispatchRawEvent( e );
					}
				}
				
			}
		
		}
		
		private function onGetPresentationInfo( result:Object ):void
		{
			if ( result.presenter.hasPresenter )
			{
				//plugin.dispatchEvent( new MadePresenterEvent( MadePresenterEvent.SWITCH_TO_VIEWER_MODE ) );
			}
			
			if ( result.presentation.xOffset )
			{
				trace( name + " Sending presenters slide settings" );
				var e:MoveEvent = new MoveEvent( MoveEvent.CUR_SLIDE_SETTING );
				e.xOffset = Number( result.presentation.xOffset );
				e.yOffset = Number( result.presentation.yOffset );
				e.slideToCanvasWidthRatio = Number( result.presentation.widthRatio );
				e.slideToCanvasHeightRatio = Number( result.presentation.heightRatio );
				trace( name + " presenter settings [" + e.xOffset + "," + e.yOffset + "," + e.slideToCanvasWidthRatio + "," + e.slideToCanvasHeightRatio + "]" );
				dispatchRawEvent( e );
			}
			
			if ( result.presentations )
			{
				for ( var p:Object in result.presentations )
				{
					var u:Object = result.presentations[ p ]
					trace( name + " Presentation name " + u as String );
					//var 
					var added:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_ADDED_EVENT );
					added.presentationName = u as String;
					dispatchRawEvent( added );
				}
			}
			
			if ( result.presentation.sharing )
			{
				currentSlide = Number( result.presentation.slide );
				
				trace( name + " The presenter has shared slides and showing slide " + currentSlide );
				
				var shareEvent:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_READY );
				shareEvent.presentationName = String( result.presentation.currentPresentation );
				dispatchRawEvent( shareEvent );
			}
		}
		
		public function upload( file:FileReference ):void
		{
			
			var fileSize:Number = file.size;
			var maxFileSize:Number = 30000000;
			var presentationName:String = file.name;
			
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
				uploadService.upload( host + "/bigbluebutton/presentation/upload", presentationName, file, conference, room );
			}
		
		}
		
		public function loadPresentation( presentationName:String ):void
		{
			if ( presentationName == _currentPresentation )
				return;
			
			trace( name + " loading " + presentationName );
			var fullUri:String = host + "/bigbluebutton/presentation/" + conference + "/" + room + "/" + presentationName + "/slides";
			fullUri = encodeURI( fullUri );
			var slideUri:String = host + "/bigbluebutton/presentation/" + conference + "/" + room + "/" + presentationName;
			slideUri = encodeURI( slideUri );
			loader.load( fullUri , slideUri );
		}
		
		public function sharePresentation( name:String, share:Boolean ):void
		{
			bbb.send( SHARE_PRESENTATION, null, name, share );
			var timer:Timer = new Timer( 3000, 1 );
			timer.addEventListener( TimerEvent.TIMER, sendViewerNotify );
			timer.start();
		}
		
		private function sendViewerNotify(e:TimerEvent):void 
		{
			gotoSlide(0);
		}
		
		public function removePresentation( name:String ):void
		{
			if ( _currentPresentation == name )
				_currentPresentation = "";
			bbb.send( REMOVE_PRESENTATION, null, name );
		}
		
		public function gotoSlide( num:Number ):void
		{
			//trace( name + " gotoSlide: " +num );
			bbb.send( GOTO_SLIDE, null, num );
		}
		
		public function resizeSlide( size:Number ):void
		{
			presentSO.resizeSlide( size );
		}
		
		private function onPresentationCursorUpdateCommand( message:Object ):void
		{
			var e:CursorEvent = new CursorEvent( CursorEvent.UPDATE_CURSOR );
			e.xPercent = message.xPercent;
			e.yPercent = message.yPercent;
			dispatchRawEvent( e );
		}
		
		public function sendCursorUpdate( xPercent:Number, yPercent:Number ):void
		{
			bbb.send( SEND_CURSOR_UPDATE, null, xPercent, yPercent );
		}
		
		public function updateSlide( xOffset:Number, yOffset:Number, widthRatio:Number, heightRatio:Number ):void
		{
			bbb.send( RESIZE_AND_MOVE_SLIDE, null, xOffset, yOffset, widthRatio, heightRatio );
		}
		
		public function onMessage( messageName:String, message:Object ):void
		{
			switch ( messageName )
			{
				case "PresentationCursorUpdateCommand": 
					onPresentationCursorUpdateCommand( message );
					break;
				default: 
			}
		}
		
		public function zoomCallback( xOffset:Number, yOffset:Number, widthRatio:Number, heightRatio:Number ):void
		{
			var e:ZoomEvent = new ZoomEvent( ZoomEvent.ZOOM );
			e.xOffset = xOffset;
			e.yOffset = yOffset;
			e.slideToCanvasWidthRatio = widthRatio;
			e.slideToCanvasHeightRatio = heightRatio;
			dispatchRawEvent( e );
		}
		
		public function resizeSlideCallback( size:Number ):void
		{
			var e:ZoomEvent = new ZoomEvent( ZoomEvent.RESIZE );
			e.zoomPercentage = size;
			dispatchRawEvent( e );
		}
		
		public function moveCallback( xOffset:Number, yOffset:Number, widthRatio:Number, heightRatio:Number ):void
		{
			var e:MoveEvent = new MoveEvent( MoveEvent.MOVE );
			e.xOffset = xOffset;
			e.yOffset = yOffset;
			e.slideToCanvasWidthRatio = widthRatio;
			e.slideToCanvasHeightRatio = heightRatio;
			dispatchRawEvent( e );
		}
		
		public function whatIsTheSlideInfo( userID:String ):void
		{
			//trace("whatIsTheSlideInfo");
			if ( presenter )
			{
				presentSO.whatIsTheSlideInfo( userID, presenterViewedRegionX, presenterViewedRegionY, presenterViewedRegionW, presenterViewedRegionH );
			}
		}
		
		public function whatIsTheSlideInfoCallback( userID:String, xOffset:Number, yOffset:Number, widthRatio:Number, heightRatio:Number ):void
		{
			trace( "whatIsTheSlideInfoCallback" );
			if ( this.userID == userID )
			{
				var e:MoveEvent = new MoveEvent( MoveEvent.CUR_SLIDE_SETTING );
				e.xOffset = xOffset;
				e.yOffset = yOffset;
				e.slideToCanvasWidthRatio = widthRatio;
				e.slideToCanvasHeightRatio = heightRatio;
				dispatchRawEvent( e );
			}
		}
		
		public function maximizeCallback():void
		{
			dispatchRawEvent( new ZoomEvent( ZoomEvent.MAXIMIZE ) );
		}
		
		public function restoreCallback():void
		{
			dispatchRawEvent( new ZoomEvent( ZoomEvent.RESTORE ) );
		}
		
		public function clearCallback():void
		{
			presentSO.setProperty( SHARING, false );
			dispatchRawEvent( new UploadEvent( UploadEvent.CLEAR_PRESENTATION ) );
		}
		
		public function gotoSlideCallback( page:Number ):void
		{
			//trace( name + " gotoSlideCallback: " + page );
			var e:NavigationEvent = new NavigationEvent( NavigationEvent.GOTO_PAGE )
			e.pageNumber = page;
			dispatchRawEvent( e );
		}
		
		public function sharePresentationCallback( name:String, share:Boolean ):void
		{
			if ( share )
			{
				var e:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_READY );
				e.presentationName = name;
				dispatchRawEvent( e );
			}
			else
			{
				dispatchRawEvent( new UploadEvent( UploadEvent.CLEAR_PRESENTATION ) );
			}
		}
		
		public function removePresentationCallback( name:String ):void
		{
			var removeEvent:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_REMOVED_EVENT );
			removeEvent.presentationName = name;
			dispatchRawEvent( removeEvent );
		}
		
		public function pageCountExceededUpdateMessageCallback( conference:String, room:String, code:String, presentationName:String, messageKey:String, numberOfPage:Number, maxNumberOfPages:Number ):void
		{
			var uploadEvent:UploadEvent = new UploadEvent( UploadEvent.PAGE_COUNT_EXCEEDED );
			uploadEvent.maximumSupportedNumberOfSlides = maxNumberOfPages;
			dispatchRawEvent( uploadEvent );
		}
		
		public function generatedSlideUpdateMessageCallback( conference:String, room:String, code:String, presentationName:String, messageKey:String, numberOfPages:Number, pagesCompleted:Number ):void
		{
			var uploadEvent:UploadEvent = new UploadEvent( UploadEvent.CONVERT_UPDATE );
			uploadEvent.totalSlides = numberOfPages;
			uploadEvent.completedSlides = pagesCompleted;
			dispatchRawEvent( uploadEvent );
		}
		
		public function conversionCompletedUpdateMessageCallback( conference:String, room:String, code:String, presentationName:String, messageKey:String, slidesInfo:String ):void
		{
			var readyEvent:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_READY );
			readyEvent.presentationName = presentationName;
			dispatchRawEvent( readyEvent );
		}
		
		public function conversionUpdateMessageCallback( conference:String, room:String, code:String, presentationName:String, messageKey:String ):void
		{
			var totalSlides:Number;
			var completedSlides:Number;
			var message:String;
			var uploadEvent:UploadEvent;
			
			trace( name + " " + messageKey );
			switch ( messageKey )
			{
				case OFFICE_DOC_CONVERSION_SUCCESS_KEY: 
					uploadEvent = new UploadEvent( UploadEvent.OFFICE_DOC_CONVERSION_SUCCESS );
					dispatchRawEvent( uploadEvent );
					break;
				case OFFICE_DOC_CONVERSION_FAILED_KEY: 
					uploadEvent = new UploadEvent( UploadEvent.OFFICE_DOC_CONVERSION_FAILED );
					dispatchRawEvent( uploadEvent );
					break;
				case SUPPORTED_DOCUMENT_KEY: 
					uploadEvent = new UploadEvent( UploadEvent.SUPPORTED_DOCUMENT );
					dispatchRawEvent( uploadEvent );
					break;
				case UNSUPPORTED_DOCUMENT_KEY: 
					uploadEvent = new UploadEvent( UploadEvent.UNSUPPORTED_DOCUMENT );
					dispatchRawEvent( uploadEvent );
					break;
				case GENERATING_THUMBNAIL_KEY: 
					uploadEvent = new UploadEvent( UploadEvent.THUMBNAILS_UPDATE );
					dispatchRawEvent( uploadEvent );
					break;
				case PAGE_COUNT_FAILED_KEY: 
					uploadEvent = new UploadEvent( UploadEvent.PAGE_COUNT_FAILED );
					dispatchRawEvent( uploadEvent );
					break;
				case GENERATED_THUMBNAIL_KEY: 
					trace( "GENERATED_THUMBNAIL_KEY " + messageKey );
					break;
				default: 
					trace( "Unknown message " + messageKey );
					break;
			}
		}
	
	}
}