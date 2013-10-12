package cc.minos.bigbluebutton.plugins.present
{
	import cc.minos.bigbluebutton.events.MadePresenterEvent;
	import cc.minos.bigbluebutton.plugins.present.events.*;
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
		
		/** 共享對象 */
		private static const SO_NAME:String = "presentationSO";
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
		
		/** 共享信息對象*/
		private var _presentationSO:SharedObject;
		/** 應用 */
		private var plugin:PresentPlugin;
		/** 網絡連接*/
		private var connection:NetConnection;
		/** 當前頁面 */
		private var currentSlide:Number = -1;
		/** 返回處理 */
		private var responder:Responder;
		
		public function PresentSOService( plugin:PresentPlugin )
		{
			this.plugin = plugin;
			responder = new Responder( function( result:Boolean ):void
				{
				}, function( status:Object ):void
				{
				} );
		}
		
		/**
		 * 連接共享信息對象
		 */
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
		
		/**
		 * 斷開共享信息對象 
		 */
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
		 * 縮放返回
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
			connection.call( SEND_CURSOR_UPDATE, responder, xPercent, yPercent );
		}
		
		/**
		 * 鼠標移動返回（0.81取消，用信息偵聽器）
		 * @param	xPercent
		 * @param	yPercent
		 */
		public function updateCursorCallback( xPercent:Number, yPercent:Number ):void
		{
			//var e:CursorEvent = new CursorEvent( CursorEvent.UPDATE_CURSOR );
			//e.xPercent = xPercent;
			//e.yPercent = yPercent;
			//plugin.dispatchEvent( e );
		}
		
		/**
		 * 重置頁面大小
		 * @param	newSizeInPercent
		 */
		public function resizeSlide( newSizeInPercent:Number ):void
		{
			_presentationSO.send( "resizeSlideCallback", newSizeInPercent );
		}
		
		/**
		 * 重置頁面大小返回
		 * @param	newSizeInPercent
		 */
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
			connection.call( RESIZE_AND_MOVE_SLIDE, responder, xOffset, yOffset, widthRatio, heightRatio );
			
			presenterViewedRegionX = xOffset;
			presenterViewedRegionY = yOffset;
			presenterViewedRegionW = widthRatio;
			presenterViewedRegionH = heightRatio;
		}
		
		/**
		 * 移動返回
		 * @param	xOffset
		 * @param	yOffset
		 * @param	widthRatio
		 * @param	heightRatio
		 */
		public function moveCallback( xOffset:Number, yOffset:Number, widthRatio:Number, heightRatio:Number ):void
		{
			var e:MoveEvent = new MoveEvent( MoveEvent.MOVE );
			e.xOffset = xOffset;
			e.yOffset = yOffset;
			e.slideToCanvasWidthRatio = widthRatio;
			e.slideToCanvasHeightRatio = heightRatio;
			plugin.dispatchEvent( e );
		}
		
		/** 頁面可視化信息 */
		private var presenterViewedRegionX:Number = 0;
		private var presenterViewedRegionY:Number = 0;
		private var presenterViewedRegionW:Number = 100;
		private var presenterViewedRegionH:Number = 100;
		
		/**
		 * 
		 */
		private function queryPresenterForSlideInfo():void
		{
			//trace( "Query for slide info" );
			_presentationSO.send( "whatIsTheSlideInfo", plugin.userID );
		}
		
		public function whatIsTheSlideInfo( userid:Number ):void
		{
			//trace( "Rx Query for slide info" );
			if ( plugin.presenter )
			{
				//trace( "User Query for slide info" );
				_presentationSO.send( "whatIsTheSlideInfoReply", userid, presenterViewedRegionX, presenterViewedRegionY, presenterViewedRegionW, presenterViewedRegionH );
			}
		}
		
		/**
		 * 
		 * @param	userId
		 * @param	xOffset
		 * @param	yOffset
		 * @param	widthRatio
		 * @param	heightRatio
		 */
		public function whatIsTheSlideInfoReply( userId:Number, xOffset:Number, yOffset:Number, widthRatio:Number, heightRatio:Number ):void
		{
			//trace( "Rx whatIsTheSlideInfoReply" );
			if ( plugin.userID == userId.toString() )
			{
				//trace( "Got reply for Query for slide info: ", userId, xOffset, yOffset, widthRatio, heightRatio );
				var e:MoveEvent = new MoveEvent( MoveEvent.CUR_SLIDE_SETTING );
				e.xOffset = xOffset;
				e.yOffset = yOffset;
				e.slideToCanvasWidthRatio = widthRatio;
				e.slideToCanvasHeightRatio = heightRatio;
				plugin.dispatchEvent( e );
			}
		
		}
		
		/**
		 * 最大化
		 */
		public function maximize():void
		{
			_presentationSO.send( "maximizeCallback" );
		}
		
		/**
		 * 最大化返回
		 */
		public function maximizeCallback():void
		{
			plugin.dispatchEvent( new ZoomEvent( ZoomEvent.MAXIMIZE ) );
		}
		
		/**
		 * 恢復
		 */
		public function restore():void
		{
			_presentationSO.send( "restoreCallback" );
		}
		
		/**
		 * 恢復返回
		 */
		public function restoreCallback():void
		{
			plugin.dispatchEvent( new ZoomEvent( ZoomEvent.RESTORE ) );
		}
		
		/**
		 * 移除文檔頁面
		 */
		public function clearPresentation():void
		{
			_presentationSO.send( "clearCallback" );
		}
		
		/**
		 * 刪除文檔
		 * @param	name
		 */
		public function removePresentation( name:String ):void
		{
			connection.call( REMOVE_PRESENTATION, responder, name );
		}
		
		/**
		 * 移除文檔返回
		 */
		public function clearCallback():void
		{
			//取消共享
			_presentationSO.setProperty( SHARING, false );
			plugin.dispatchEvent( new UploadEvent( UploadEvent.CLEAR_PRESENTATION ) );
		}
		
		/**
		 * 
		 * @param	presenterName
		 */
		public function setPresenterName( presenterName:String ):void
		{
			_presentationSO.setProperty( PRESENTER, presenterName );
		}
		
		/**
		 * 獲取文檔信息
		 */
		public function getPresentationInfo():void
		{
			plugin.connection.call( GET_PRESENTATION_INFO, new Responder( function( result:Object ):void
				{
					//Console.log( "Successfully querried for presentation information." );
					
					//
					if ( result.presenter.hasPresenter )
					{
						plugin.dispatchEvent( new MadePresenterEvent( MadePresenterEvent.SWITCH_TO_VIEWER_MODE ) );
					}
					
					//如果有坐標信息
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
					
					//當前服務器上的文檔列表
					if ( result.presentations )
					{
						for ( var p:Object in result.presentations )
						{
							var u:Object = result.presentations[ p ]
							//Console.log( "Presentation name " + u as String );
							//var 
							var added:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_ADDED_EVENT );
							added.presentationName = u as String;
							plugin.dispatchEvent( added );
						}
					}
					
					// Force switching the presenter.
					triggerSwitchPresenter();
					
					//有無文檔正在演示
					if ( result.presentation.sharing )
					{
						currentSlide = Number( result.presentation.slide );
						//Console.log( "The presenter has shared slides and showing slide " + currentSlide );
						var shareEvent:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_READY );
						shareEvent.presentationName = String( result.presentation.currentPresentation );
						plugin.dispatchEvent( shareEvent );
					}
				}, function( status:Object ):void
				{
				} ) );
		}
		
		/**
		 * 轉換權限
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
		 * 跳轉頁面
		 * @param page
		 */
		public function gotoSlide( num:int ):void
		{
			connection.call( GOTO_SLIDE, 
				responder, num );
		}
		
		/**
		 * 跳轉頁面返回
		 * @param page
		 */
		public function gotoSlideCallback( page:Number ):void
		{
			var e:NavigationEvent = new NavigationEvent( NavigationEvent.GOTO_PAGE )
			e.pageNumber = page;
			plugin.dispatchEvent( e );
		}
		
		/**
		 * 獲取當前頁面
		 */
		public function getCurrentSlideNumber():void
		{
			if ( currentSlide >= 0 )
			{
				var e:NavigationEvent = new NavigationEvent( NavigationEvent.GOTO_PAGE )
				e.pageNumber = currentSlide;
				plugin.dispatchEvent( e );
			}
		}
		
		/**
		 * 設置文檔是否共享演示
		 * @param	share
		 * @param	presentationName
		 */
		public function sharePresentation( share:Boolean, presentationName:String ):void
		{
			Console.log( "sharePresentation presentationName=" + presentationName );
			connection.call( SHARE_PRESENTATION, responder, presentationName, share );
		}
		
		/**
		 * 設置文檔是否共享演示返回
		 * @param	presentationName
		 * @param	share
		 */
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
		
		/**
		 * 移除文檔返回
		 * @param	presentationName
		 */
		public function removePresentationCallback( presentationName:String ):void
		{
			Console.log( "removePresentationCallback " + presentationName );
			var removeEvent:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_REMOVED_EVENT );
			removeEvent.presentationName = presentationName;
			plugin.dispatchEvent( removeEvent );
		}
		
		/**
		 * 
		 * @param	conference
		 * @param	room
		 * @param	code
		 * @param	presentationName
		 * @param	messageKey
		 * @param	numberOfPages
		 * @param	maxNumberOfPages
		 */
		public function pageCountExceededUpdateMessageCallback( conference:String, room:String, code:String, presentationName:String, messageKey:String, numberOfPages:Number, maxNumberOfPages:Number ):void
		{
			Console.log( "Received update message " + messageKey );
			var uploadEvent:UploadEvent = new UploadEvent( UploadEvent.PAGE_COUNT_EXCEEDED );
			uploadEvent.maximumSupportedNumberOfSlides = maxNumberOfPages;
			plugin.dispatchEvent( uploadEvent );
		}
		
		/**
		 * 
		 * @param	conference
		 * @param	room
		 * @param	code
		 * @param	presentationName
		 * @param	messageKey
		 * @param	numberOfPages
		 * @param	pagesCompleted
		 */
		public function generatedSlideUpdateMessageCallback( conference:String, room:String, code:String, presentationName:String, messageKey:String, numberOfPages:Number, pagesCompleted:Number ):void
		{
			Console.log( "CONVERTING = [" + pagesCompleted + " of " + numberOfPages + "]" );
			var uploadEvent:UploadEvent = new UploadEvent( UploadEvent.CONVERT_UPDATE );
			uploadEvent.totalSlides = numberOfPages;
			uploadEvent.completedSlides = pagesCompleted;
			plugin.dispatchEvent( uploadEvent );
		}
		
		/**
		 * 
		 * @param	conference
		 * @param	room
		 * @param	code
		 * @param	presentationName
		 * @param	messageKey
		 * @param	slidesInfo
		 */
		public function conversionCompletedUpdateMessageCallback( conference:String, room:String, code:String, presentationName:String, messageKey:String, slidesInfo:String ):void
		{
			Console.log( "Received update message " + messageKey );
			var readyEvent:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_READY );
			readyEvent.presentationName = presentationName;
			plugin.dispatchEvent( readyEvent );
		}
		
		/**
		 * 
		 * @param	conference
		 * @param	room
		 * @param	code
		 * @param	presentationName
		 * @param	messageKey
		 */
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
		
		private function syncHandler( event:SyncEvent ):void
		{
			getPresentationInfo();
			queryPresenterForSlideInfo();
		}
		
		private function netStatusHandler( event:NetStatusEvent ):void
		{
			var statusCode:String = event.info.code;
			//trace( "!!!!! Presentation status handler - " + statusCode );
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