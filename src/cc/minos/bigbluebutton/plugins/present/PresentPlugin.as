package cc.minos.bigbluebutton.plugins.present
{
	import cc.minos.bigbluebutton.interfaces.IMessageListener;
	import cc.minos.bigbluebutton.plugins.Plugin;
	import cc.minos.bigbluebutton.plugins.present.events.*;
	import cc.minos.console.Console;
	import cc.minos.utils.ArrayUtil;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * 演示應用
	 * 上傳文檔轉換，演示
	 * @author Minos
	 */
	public class PresentPlugin extends Plugin implements IMessageListener
	{
		/** 文檔演示數據加載服務 */
		private var service:PresentationService;
		/** 同步服務 */
		private var soService:PresentSOService;
		/** 文檔上傳服務 */
		private var uploadService:FileUploadService;
		/** 服務器地址 */
		private var host:String;
		/** 會議 */
		private var conference:String;
		/** 房間 */
		private var room:String;
		/** 當前文檔演示名稱 */
		private var _currentPresentation:String;
		/** 文檔數組 */
		public var presentationNames:Array;
		/** 頁面數組 */
		public var slides:Array;
		
		public function PresentPlugin()
		{
			super();
			this.name = "[PresentPlugin]";
			this.shortcut = "present";
		}
		
		/**
		 *
		 */
		override protected function init():void
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
			
			this.addEventListener( PresentationEvent.PRESENTATION_ADDED_EVENT, onPresentation );
			this.addEventListener( PresentationEvent.PRESENTATION_REMOVED_EVENT, onPresentation );
		}
		
		/**
		 *
		 * @param	e
		 */
		private function onPresentation( e:PresentationEvent ):void
		{
			if ( e.type == PresentationEvent.PRESENTATION_ADDED_EVENT )
			{
				if ( !ArrayUtil.containsValue( presentationNames, e.presentationName ) )
					presentationNames.push( e.presentationName );
			}
			else if ( e.type == PresentationEvent.PRESENTATION_REMOVED_EVENT )
			{
				for ( var i:int = 0; i < presentationNames.length; i++ )
				{
					if ( presentationNames[ i ] == e.presentationName )
						presentationNames.splice( i, 1 );
				}
			}
		}
		
		/**
		 * 演示xml數據加載完成
		 * @param	presentationName
		 * @param	slides
		 */
		private function onPresentationDataCompleted( presentationName:String, slides:Array ):void
		{
			if ( slides.length > 0 )
			{
				if ( presentationName == _currentPresentation )
					return;
				
				Console.log( 'presentation has been loaded  presentationName=' + presentationName );
				
				var added:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_ADDED_EVENT );
				added.presentationName = presentationName;
				dispatchEvent( added );
					
				_currentPresentation = presentationName;
				
				var loadedEvent:PresentationEvent = new PresentationEvent( PresentationEvent.PRESENTATION_LOADED );
				loadedEvent.presentationName = presentationName;
				loadedEvent.slides = slides;
				dispatchEvent( loadedEvent );
				
				if ( presenter )
				{
					//设置文档共享信息为true，通知其他用户
					sharePresentation( true, presentationName );
				}
				else
				{
					//加載當前頁
					loadCurrentSlideLocally();
				}
				
			}
			else
			{
				trace( 'failed to load presentation' );
			}
		}
		
		/**
		 * 服務器地址
		 */
		override public function get uri():String
		{
			var _uri:String = super.uri + "/" + bbb.conferenceParameters.room;
			return _uri;
		}
		
		/**
		 * 啟用文檔演示應用
		 */
		override public function start():void
		{
			soService.connect();
			bbb.addMessageListener( this );
		}
		
		/**
		 * 停用文檔演示應用
		 */
		override public function stop():void
		{
			soService.disconnect();
			bbb.removeMessageListener( this );
		}
		
		/**
		 * 開始上傳
		 * @param	presentationName
		 * @param	file
		 */
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
		
		/**
		 * 跳轉頁面
		 * @param	slideNumber	:	頁面>=0
		 */
		public function gotoSlide( slideNumber:Number ):void
		{
			soService.gotoSlide( slideNumber );
		}
		
		/**
		 * 加載當前頁
		 */
		public function loadCurrentSlideLocally():void
		{
			soService.getCurrentSlideNumber();
		}
		
		/**
		 * 重置大小
		 */
		public function resetZoom():void
		{
			soService.restore();
		}
		
		/**
		 * 加載演示數據
		 * @param	presentationName
		 */
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
		
		/**
		 * 共享演示文件
		 * @param	share
		 * @param	presentationName
		 */
		public function sharePresentation( share:Boolean, presentationName:String ):void
		{
			soService.sharePresentation( share, presentationName );
			var timer:Timer = new Timer( 3000, 1 );
			timer.addEventListener( TimerEvent.TIMER, sendViewerNotify );
			timer.start();
		}
		
		/**
		 * 移除
		 * @param	presentationName
		 */
		public function removePresentation( presentationName:String ):void
		{
			soService.removePresentation( presentationName );
		}
		
		/**
		 * 共享文檔後加載第一頁
		 * @param	e
		 */
		private function sendViewerNotify( e:TimerEvent ):void
		{
			soService.gotoSlide( 0 );
		}
		
		/**
		 * 移動頁面
		 * @param	xOffset
		 * @param	yOffset
		 * @param	slideToCanvasWidthRatio
		 * @param	slideToCanvasHeightRatio
		 */
		public function moveSlide( xOffset:Number, yOffset:Number, slideToCanvasWidthRatio:Number, slideToCanvasHeightRatio:Number ):void
		{
			soService.move( xOffset, yOffset, slideToCanvasWidthRatio, slideToCanvasHeightRatio );
		}
		
		/**
		 * 縮放頁面
		 * @param	xOffset
		 * @param	yOffset
		 * @param	slideToCanvasWidthRatio
		 * @param	slideToCanvasHeightRatio
		 */
		public function zoomSlide( xOffset:Number, yOffset:Number, slideToCanvasWidthRatio:Number, slideToCanvasHeightRatio:Number ):void
		{
			soService.zoom( xOffset, yOffset, slideToCanvasWidthRatio, slideToCanvasHeightRatio );
		}
		
		/**
		 * 發送鼠標位置到服務器
		 * @param	xPercent
		 * @param	yPercent
		 */
		public function sendCursorUpdate( xPercent:Number, yPercent:Number ):void
		{
			soService.sendCursorUpdate( xPercent, yPercent );
		}
		
		/**
		 * 設置頁面大小
		 * @param	newSizeInPercent
		 */
		public function resizeSlide( newSizeInPercent:Number ):void
		{
			soService.resizeSlide( newSizeInPercent );
		}
		
		/* INTERFACE cc.minos.bigbluebutton.extensions.IMessageListener (信息偵聽器) */
		
		/**
		 *
		 * @param	messageName
		 * @param	message
		 */
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
		
		/**
		 * 鼠標移送處理
		 * @param	message
		 */
		private function onPresentationCursorUpdateCommand( message:Object ):void
		{
			var e:CursorEvent = new CursorEvent( CursorEvent.UPDATE_CURSOR );
			e.xPercent = message.xPercent;
			e.yPercent = message.yPercent;
			dispatchEvent( e );
		}
	}

}