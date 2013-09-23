package cc.minos.bigbluebutton.plugins.present
{
	import cc.minos.bigbluebutton.events.MadePresenterEvent;
	import cc.minos.bigbluebutton.plugins.present.events.*;
	import cc.minos.bigbluebutton.plugins.PresentPlugin;
	import cc.minos.console.Console;
	import flash.events.AsyncErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SyncEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.SharedObject;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class PresentSOService
	{
		private static const OFFICE_DOC_CONVERSION_SUCCESS_KEY:String = "OFFICE_DOC_CONVERSION_SUCCESS";
		private static const OFFICE_DOC_CONVERSION_FAILED_KEY:String = "OFFICE_DOC_CONVERSION_FAILED";
		private static const SUPPORTED_DOCUMENT_KEY:String = "SUPPORTED_DOCUMENT";
		private static const UNSUPPORTED_DOCUMENT_KEY:String = "UNSUPPORTED_DOCUMENT";
		private static const PAGE_COUNT_FAILED_KEY:String = "PAGE_COUNT_FAILED";
		private static const PAGE_COUNT_EXCEEDED_KEY:String = "PAGE_COUNT_EXCEEDED";
		private static const GENERATED_SLIDE_KEY:String = "GENERATED_SLIDE";
		private static const GENERATING_THUMBNAIL_KEY:String = "GENERATING_THUMBNAIL";
		private static const GENERATED_THUMBNAIL_KEY:String = "GENERATED_THUMBNAIL";
		private static const CONVERSION_COMPLETED_KEY:String = "CONVERSION_COMPLETED";
		
		private static const SO_NAME:String = "presentationSO";
		private static const SEND_CURSOR_UPDATE:String = "presentation.sendCursorUpdate";
		private static const RESIZE_AND_MOVE_SLIDE:String = "presentation.resizeAndMoveSlide";
		private static const REMOVE_PRESENTATION:String = "presentation.removePresentation";
		private static const GET_PRESENTATION_INFO:String = "presentation.getPresentationInfo";
		private static const GOTO_SLIDE:String = "presentation.gotoSlide";
		private static const SHARE_PRESENTATION:String = "presentation.sharePresentation";
		
		private static const PRESENTER:String = "presenter";
		private static const SHARING:String = "sharing";
		private static const UPDATE_MESSAGE:String = "updateMessage";
		private static const CURRENT_PAGE:String = "currentPage";
		
		private var _presentationSO:SharedObject;
		private var plugin:PresentPlugin;
		private var connection:NetConnection;
		private var currentSlide:Number = -1;
		
		public function PresentSOService( plugin:PresentPlugin )
		{
			this.plugin = plugin;
		}
		
		public function connect():void
		{
			connection = plugin.connection;
			_presentationSO = SharedObject.getRemote( SO_NAME, plugin.uri, false );
			_presentationSO.client = this;
			_presentationSO.addEventListener( SyncEvent.SYNC, syncHandler );
			_presentationSO.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			_presentationSO.addEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler );
			_presentationSO.connect( connection );
		}
		
		public function disconnect():void
		{
			if ( _presentationSO != null )
				_presentationSO.close();
		}
		
		/**
		 * 縮放
		 * @param	xOffset
		 * @param	yOffset
		 * @param	widthRatio
		 * @param	heightRatio
		 */
		public function zoom( xOffset:Number, yOffset:Number, widthRatio:Number, heightRatio:Number ):void
		{
			move( xOffset, yOffset, widthRatio, heightRatio );
		}
		
		/**
		 *
		 * @param	xOffset
		 * @param	yOffset
		 * @param	widthRatio
		 * @param	heightRatio
		 */
		public function zoomCallback( xOffset:Number, yOffset:Number, widthRatio:Number, heightRatio:Number ):void
		{
			var e:ZoomEvent = new ZoomEvent( ZoomEvent.ZOOM );
			e.xOffset = xOffset;
			e.yOffset = yOffset;
			e.slideToCanvasWidthRatio = widthRatio;
			e.slideToCanvasHeightRatio = heightRatio;
			plugin.dispatchEvent( e );
		}
		
		/**
		 * 鼠標
		 * @param	xPercent
		 * @param	yPercent
		 */
		public function sendCursorUpdate( xPercent:Number, yPercent:Number ):void
		{
			connection.call( SEND_CURSOR_UPDATE, new Responder( function( result:Boolean ):void
				{
					if ( result )
					{
						trace( "Successfully sent sendCursorUpdate" );
					}
				}, function( status:Object ):void
				{
				} ), xPercent, yPercent );
		}
		
		public function updateCursorCallback( xPercent:Number, yPercent:Number ):void
		{
			//var e:CursorEvent = new CursorEvent( CursorEvent.UPDATE_CURSOR );
			//e.xPercent = xPercent;
			//e.yPercent = yPercent;
			//plugin.dispatchEvent( e );
		}
		
		/**
		 *
		 * @param	newSizeInPercent
		 */
		public function resizeSlide( newSizeInPercent:Number ):void
		{
			_presentationSO.send( "resizeSlideCallback", newSizeInPercent );
		}
		
		public function resizeSlideCallback( newSizeInPercent:Number ):void
		{
			var e:ZoomEvent = new ZoomEvent( ZoomEvent.RESIZE );
			e.zoomPercentage = newSizeInPercent;
			plugin.dispatchEvent( e );
		}
		
		/**
		 * 移動
		 * @param	xOffset
		 * @param	yOffset
		 * @param	widthRatio
		 * @param	heightRatio
		 */
		public function move( xOffset:Number, yOffset:Number, widthRatio:Number, heightRatio:Number ):void
		{
			connection.call( RESIZE_AND_MOVE_SLIDE, new Responder( function( result:Boolean ):void
				{
					if ( result )
					{
						trace( "Successfully sent resizeAndMoveSlide" );
					}
				}, function( status:Object ):void
				{
				} ), xOffset, yOffset, widthRatio, heightRatio );
			
			presenterViewedRegionX = xOffset;
			presenterViewedRegionY = yOffset;
			presenterViewedRegionW = widthRatio;
			presenterViewedRegionH = heightRatio;
		}
		
		public function moveCallback( xOffset:Number, yOffset:Number, widthRatio:Number, heightRatio:Number ):void
		{
			var e:MoveEvent = new MoveEvent( MoveEvent.MOVE );
			e.xOffset = xOffset;
			e.yOffset = yOffset;
			e.slideToCanvasWidthRatio = widthRatio;
			e.slideToCanvasHeightRatio = heightRatio;
			plugin.dispatchEvent( e );
		}
		
		private var presenterViewedRegionX:Number = 0;
		private var presenterViewedRegionY:Number = 0;
		private var presenterViewedRegionW:Number = 100;
		private var presenterViewedRegionH:Number = 100;
		
		/**
		 *
		 */
		private function queryPresenterForSlideInfo():void
		{
			trace( "Query for slide info" );
			_presentationSO.send( "whatIsTheSlideInfo", plugin.userID );
		}
		
		public function whatIsTheSlideInfo( userid:Number ):void
		{
			trace( "Rx Query for slide info" );
			if ( plugin.presenter )
			{
				trace( "User Query for slide info" );
				_presentationSO.send( "whatIsTheSlideInfoReply", userid, presenterViewedRegionX, presenterViewedRegionY, presenterViewedRegionW, presenterViewedRegionH );
			}
		}
		
		public function whatIsTheSlideInfoReply( userId:Number, xOffset:Number, yOffset:Number, widthRatio:Number, heightRatio:Number ):void
		{
			trace( "Rx whatIsTheSlideInfoReply" );
			if ( plugin.userID == userId.toString() )
			{
				trace( "Got reply for Query for slide info: ", userId, xOffset, yOffset, widthRatio, heightRatio );
				var e:MoveEvent = new MoveEvent( MoveEvent.CUR_SLIDE_SETTING );
				e.xOffset = xOffset;
				e.yOffset = yOffset;
				e.slideToCanvasWidthRatio = widthRatio;
				e.slideToCanvasHeightRatio = heightRatio;
				plugin.dispatchEvent( e );
			}
		
		}
		
		/**
		 * Sends an event out for the clients to maximize the presentation module
		 *
		 */
		public function maximize():void
		{
			_presentationSO.send( "maximizeCallback" );
		}
		
		/**
		 * A callback method from the server to maximize the presentation
		 *
		 */
		public function maximizeCallback():void
		{
			plugin.dispatchEvent( new ZoomEvent( ZoomEvent.MAXIMIZE ) );
		}
		
		public function restore():void
		{
			_presentationSO.send( "restoreCallback" );
		}
		
		public function restoreCallback():void
		{
			plugin.dispatchEvent( new ZoomEvent( ZoomEvent.RESTORE ) );
		}
		
		/**
		 * Send an event to the server to clear the presentation
		 *
		 */
		public function clearPresentation():void
		{
			_presentationSO.send( "clearCallback" );
		}
		
		public function removePresentation( name:String ):void
		{
			connection.call( REMOVE_PRESENTATION, new Responder( function( result:Boolean ):void
				{
					if ( result )
					{
						trace( "Successfully assigned presenter to: " + plugin.userID );
					}
				}, function( status:Object ):void
				{
				} ), name );
		}
		
		/**
		 * A call-back method for the clear method. This method is called when the clear method has
		 * successfuly called the server.
		 *
		 */
		public function clearCallback():void
		{
			_presentationSO.setProperty( SHARING, false );
			plugin.dispatchEvent( new UploadEvent( UploadEvent.CLEAR_PRESENTATION ) );
		}
		
		public function setPresenterName( presenterName:String ):void
		{
			_presentationSO.setProperty( PRESENTER, presenterName );
		}
		
		public function getPresentationInfo():void
		{
			plugin.connection.call( GET_PRESENTATION_INFO, new Responder( function( result:Object ):void
				{
					Console.log( "Successfully querried for presentation information." );
					if ( result.presenter.hasPresenter )
					{
						plugin.dispatchEvent( new MadePresenterEvent( MadePresenterEvent.SWITCH_TO_VIEWER_MODE ) );
					}
					
					if ( result.presentation.xOffset )
					{
						Console.log( "Sending presenters slide settings" );
						var e:MoveEvent = new MoveEvent( MoveEvent.CUR_SLIDE_SETTING );
						e.xOffset = Number( result.presentation.xOffset );
						e.yOffset = Number( result.presentation.yOffset );
						e.slideToCanvasWidthRatio = Number( result.presentation.widthRatio );
						e.slideToCanvasHeightRatio = Number( result.presentation.heightRatio );
						Console.log( "****presenter settings [" + e.xOffset + "," + e.yOffset + "," + e.slideToCanvasWidthRatio + "," + e.slideToCanvasHeightRatio + "]" );
						plugin.dispatchEvent( e );
					}
					if ( result.presentations )
					{
						for ( var p:Object in result.presentations )
						{
							var u:Object = result.presentations[ p ]
							Console.log( "Presentation name " + u as String );
							//var 
							var added:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_ADDED_EVENT );
							added.presentationName = u as String;
							plugin.dispatchEvent( added );
						}
					}
					
					// Force switching the presenter.
					triggerSwitchPresenter();
					
					if ( result.presentation.sharing )
					{
						currentSlide = Number( result.presentation.slide );
						Console.log( "The presenter has shared slides and showing slide " + currentSlide );
						var shareEvent:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_READY );
						shareEvent.presentationName = String( result.presentation.currentPresentation );
						plugin.dispatchEvent( shareEvent );
					}
				}, function( status:Object ):void
				{
				} ) );
		}
		
		/***
		 * NOTE:
		 * This is a workaround to trigger the UI to switch to presenter or viewer.
		 * The reason is that when the user joins, the MadePresenterEvent in UserServiceSO
		 * doesn't get received by the modules as the modules hasn't started yet.
		 * Need to redo the proper sequence of events but will take a lot of changes.
		 * (ralam dec 8, 2011).
		 */
		public function triggerSwitchPresenter():void
		{
			var event:MadePresenterEvent;
			if ( plugin.presenter )
			{
				event = new MadePresenterEvent( MadePresenterEvent.SWITCH_TO_PRESENTER_MODE );
			}
			else
			{
				event = new MadePresenterEvent( MadePresenterEvent.SWITCH_TO_VIEWER_MODE );
			}
			event.userID = plugin.userID;
			plugin.dispatchEvent( event );
		}
		
		/**
		 * Send an event out to the server to go to a new page in the SlidesDeck
		 * @param page
		 *
		 */
		public function gotoSlide( num:int ):void
		{
			connection.call( GOTO_SLIDE, // Remote function name
				new Responder( function( result:Object ):void
				{
					if ( result )
					{
						trace( "Successfully moved page to: " + num );
					}
				}, function( status:Object ):void
				{
				//trace( status );
				} ), num );
		}
		
		/**
		 * A callback method. It is called after the gotoPage method has successfully executed on the server
		 * The method sets the clients view to the page number received
		 * @param page
		 *
		 */
		public function gotoSlideCallback( page:Number ):void
		{
			var e:NavigationEvent = new NavigationEvent( NavigationEvent.GOTO_PAGE )
			e.pageNumber = page;
			plugin.dispatchEvent( e );
		}
		
		public function getCurrentSlideNumber():void
		{
			if ( currentSlide >= 0 )
			{
				var e:NavigationEvent = new NavigationEvent( NavigationEvent.GOTO_PAGE )
				e.pageNumber = currentSlide;
				plugin.dispatchEvent( e );
			}
		}
		
		public function sharePresentation( share:Boolean, presentationName:String ):void
		{
			Console.log( "sharePresentation presentationName=" + presentationName );
			connection.call( SHARE_PRESENTATION, // Remote function name
				new Responder( function( result:Boolean ):void
				{
					if ( result )
					{
						trace( "Successfully shared presentation" );
					}
				}, 
				// status - On error occurred
				function( status:Object ):void
				{
				} ), //new Responder
				presentationName, share ); //_netConnection.call
		}
		
		public function sharePresentationCallback( presentationName:String, share:Boolean ):void
		{
			Console.log( "sharePresentationCallback " + presentationName + "," + share );
			if ( share )
			{
				var e:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_READY );
				e.presentationName = presentationName;
				plugin.dispatchEvent( e );
			}
			else
			{
				plugin.dispatchEvent( new UploadEvent( UploadEvent.CLEAR_PRESENTATION ) );
			}
		}
		
		public function removePresentationCallback( presentationName:String ):void
		{
			Console.log( "removePresentationCallback " + presentationName );
			var removeEvent:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_REMOVED_EVENT );
			removeEvent.presentationName = presentationName;
			plugin.dispatchEvent( removeEvent );
		}
		
		public function pageCountExceededUpdateMessageCallback( conference:String, room:String, code:String, presentationName:String, messageKey:String, numberOfPages:Number, maxNumberOfPages:Number ):void
		{
			Console.log( "Received update message " + messageKey );
			var uploadEvent:UploadEvent = new UploadEvent( UploadEvent.PAGE_COUNT_EXCEEDED );
			uploadEvent.maximumSupportedNumberOfSlides = maxNumberOfPages;
			plugin.dispatchEvent( uploadEvent );
		}
		
		public function generatedSlideUpdateMessageCallback( conference:String, room:String, code:String, presentationName:String, messageKey:String, numberOfPages:Number, pagesCompleted:Number ):void
		{
			Console.log( "CONVERTING = [" + pagesCompleted + " of " + numberOfPages + "]" );
			var uploadEvent:UploadEvent = new UploadEvent( UploadEvent.CONVERT_UPDATE );
			uploadEvent.totalSlides = numberOfPages;
			uploadEvent.completedSlides = pagesCompleted;
			plugin.dispatchEvent( uploadEvent );
		}
		
		public function conversionCompletedUpdateMessageCallback( conference:String, room:String, code:String, presentationName:String, messageKey:String, slidesInfo:String ):void
		{
			Console.log( "Received update message " + messageKey );
			var readyEvent:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_READY );
			readyEvent.presentationName = presentationName;
			plugin.dispatchEvent( readyEvent );
		}
		
		public function conversionUpdateMessageCallback( conference:String, room:String, code:String, presentationName:String, messageKey:String ):void
		{
			Console.log( "Received update message " + messageKey );
			var totalSlides:Number;
			var completedSlides:Number;
			var message:String;
			var uploadEvent:UploadEvent;
			
			switch ( messageKey )
			{
				case OFFICE_DOC_CONVERSION_SUCCESS_KEY: 
					uploadEvent = new UploadEvent( UploadEvent.OFFICE_DOC_CONVERSION_SUCCESS );
					plugin.dispatchEvent( uploadEvent );
					break;
				case OFFICE_DOC_CONVERSION_FAILED_KEY: 
					uploadEvent = new UploadEvent( UploadEvent.OFFICE_DOC_CONVERSION_FAILED );
					plugin.dispatchEvent( uploadEvent );
					break;
				case SUPPORTED_DOCUMENT_KEY: 
					uploadEvent = new UploadEvent( UploadEvent.SUPPORTED_DOCUMENT );
					plugin.dispatchEvent( uploadEvent );
					break;
				case UNSUPPORTED_DOCUMENT_KEY: 
					uploadEvent = new UploadEvent( UploadEvent.UNSUPPORTED_DOCUMENT );
					plugin.dispatchEvent( uploadEvent );
					break;
				case GENERATING_THUMBNAIL_KEY: 
					plugin.dispatchEvent( new UploadEvent( UploadEvent.THUMBNAILS_UPDATE ) );
					break;
				case PAGE_COUNT_FAILED_KEY: 
					uploadEvent = new UploadEvent( UploadEvent.PAGE_COUNT_FAILED );
					plugin.dispatchEvent( uploadEvent );
					break;
				case GENERATED_THUMBNAIL_KEY: 
					trace( "GENERATED_THUMBNAIL_KEY " + messageKey );
					break;
				default: 
					trace( "Unknown message " + messageKey );
					break;
			}
		}
		
		private function notifyConnectionStatusListener( connected:Boolean, errors:Array = null ):void
		{
		/*if ( _connectionListener != null )
		   {
		   _connectionListener( connected, errors );
		 }*/
		}
		
		private function syncHandler( event:SyncEvent ):void
		{
			//		var statusCode:String = event.info.code;
			trace( "!!!!! Presentation sync handler - " + event.changeList.length );
			//notifyConnectionStatusListener( true );
			getPresentationInfo();
			queryPresenterForSlideInfo();
		}
		
		private function netStatusHandler( event:NetStatusEvent ):void
		{
			var statusCode:String = event.info.code;
			trace( "!!!!! Presentation status handler - " + statusCode );
			switch ( statusCode )
			{
				case "NetConnection.Connect.Success": 
					trace( "Connection Success" );
					getPresentationInfo();
					break;
				case "NetConnection.Connect.Failed": 
					trace( "PresentSO connection failed" );
					break;
				case "NetConnection.Connect.Closed": 
					trace( "Connection to PresentSO was closed." );
					break;
				case "NetConnection.Connect.InvalidApp": 
					trace( "PresentSO not found in server" );
					break;
				case "NetConnection.Connect.AppShutDown": 
					trace( "PresentSO is shutting down" );
					break;
				case "NetConnection.Connect.Rejected": 
					trace( "No permissions to connect to the PresentSO" );
					break;
				default: 
					break;
			}
		}
		
		private function asyncErrorHandler( event:AsyncErrorEvent ):void
		{
			trace( "PresentSO asynchronous error." );
		}
	}

}