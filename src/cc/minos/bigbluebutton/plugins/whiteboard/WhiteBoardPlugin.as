package cc.minos.bigbluebutton.plugins.whiteboard
{
	import cc.minos.bigbluebutton.interfaces.IMessageListener;
	import cc.minos.bigbluebutton.plugins.Plugin;
	import cc.minos.bigbluebutton.plugins.present.events.NavigationEvent;
	import cc.minos.bigbluebutton.plugins.present.events.PresentationEvent;
	import cc.minos.bigbluebutton.plugins.present.PresentPlugin;
	import cc.minos.bigbluebutton.plugins.whiteboard.models.*;
	import cc.minos.bigbluebutton.plugins.whiteboard.shapes.DrawAnnotation;
	import cc.minos.console.Console;
	
	/**
	 * 白板應用
	 * @author Minos
	 */
	public class WhiteBoardPlugin extends Plugin implements IMessageListener
	{
		private var service:WhiteBoardService;
		public var whiteboardModel:WhiteboardModel;
		private var presentPlugin:PresentPlugin;
		
		public function WhiteBoardPlugin()
		{
			super();
			this.name = "[WhiteBoardPlugin]";
			this.shortcut = "board";
		}
		
		override protected function init():void
		{
			super.init();
			
			service = new WhiteBoardService( this );
			whiteboardModel = new WhiteboardModel( this );
		}
		
		/**
		 * 啟用白板應用（需啟用演示文檔應用）
		 */
		override public function start():void
		{
			presentPlugin = bbb.getPlugin( "present" ) as PresentPlugin;
			if ( presentPlugin == null )
			{
				Console.log( "", null, Console.ERROR );
				return;
			}
			
			presentPlugin.addEventListener( PresentationEvent.PRESENTATION_LOADED, onPresentation );
			presentPlugin.addEventListener( NavigationEvent.GOTO_PAGE, onGotoPage );
			bbb.addMessageListener( this );
		}
		
		override public function stop():void
		{
			super.stop();
			if ( presentPlugin != null )
			{
				presentPlugin.removeEventListener( PresentationEvent.PRESENTATION_LOADED, onPresentation );
				presentPlugin.removeEventListener( NavigationEvent.GOTO_PAGE, onGotoPage );
			}
			bbb.removeMessageListener( this );
		}
		
		private var count:uint = 0;
		
		public function generateID():String
		{
			var curTime:Number = new Date().getTime();
			return bbb.conferenceParameters.userID + "-" + count++ + "-" + curTime;
		}
		
		/**
		 * 
		 * @param	e
		 */
		private function onPresentation( e:PresentationEvent ):void
		{
			setActivePresentation( e.presentationName, e.slides.length );
		}
		
		/**
		 * 演示文檔頁面跳轉
		 * @param	e
		 */
		private function onGotoPage( e:NavigationEvent ):void
		{
			changePage( e.pageNumber );
		}
		
		/**
		 *
		 */
		public function getAnnotationHistory():void
		{
			var cp:Object = whiteboardModel.getCurrentPresentationAndPage();
			if ( cp != null )
			{
				service.requestAnnotationHistory( cp.presentationID, cp.currentPageNumber );
			}
		}
		
		public function modifyEnabled( enabled:Boolean ):void
		{
			service.modifyEnabled( enabled );
		}
		
		/**
		 * 跳轉頁面
		 * @param	pageNum
		 */
		public function changePage( pageNum:Number ):void
		{
			pageNum += 1;
			if ( presenter )
			{
				service.changePage( pageNum );
			}
			else
			{
				whiteboardModel.changePage( pageNum, 0 );
			}
		}
		
		public function toggleGrid():void
		{
			service.toggleGrid();
		}
		
		public function undoGraphic():void
		{
			service.undoGraphic();
		}
		
		public function clearBoard():void
		{
			service.clearBoard();
		}
		
		public function sendAnnotation( annotation:Annotation ):void
		{
			service.sendAnnotation( annotation );
		}
		
		public function checkIsWhiteboardOn():void
		{
			service.checkIsWhiteboardOn();
		}
		
		public function setActivePresentation( presentationName:String, numberOfPages:int ):void
		{
			if ( presenter )
			{
				service.setActivePresentation( presentationName, numberOfPages );
			}
			else
			{
				whiteboardModel.changePresentation( presentationName, numberOfPages );
			}
		}
		
		/* INTERFACE cc.minos.bigbluebutton.extensions.IMessageListener */
		
		public function onMessage( messageName:String, message:Object ):void
		{
			switch ( messageName )
			{
				case "WhiteboardRequestAnnotationHistoryReply": 
					handleRequestAnnotationHistoryReply( message );
					break;
				case "WhiteboardIsWhiteboardEnabledReply": 
					handleIsWhiteboardEnabledReply( message );
					break;
				case "WhiteboardEnableWhiteboardCommand": 
					handleEnableWhiteboardCommand( message );
					break;
				case "WhiteboardNewAnnotationCommand": 
					handleNewAnnotationCommand( message );
					break;
				case "WhiteboardClearCommand": 
					handleClearCommand( message );
					break;
				case "WhiteboardUndoCommand": 
					handleUndoCommand( message );
					break;
				case "WhiteboardChangePageCommand": 
					handleChangePageCommand( message );
					break;
				case "WhiteboardChangePresentationCommand": 
					handleChangePresentationCommand( message );
					break;
				default: 
			}
		
		}
		
		private function handleChangePresentationCommand( message:Object ):void
		{
			whiteboardModel.changePresentation( message.presentationID, message.numberOfPages );
		}
		
		private function handleChangePageCommand( message:Object ):void
		{
			whiteboardModel.changePage( message.pageNum, message.numAnnotations );
		}
		
		private function handleClearCommand( message:Object ):void
		{
			whiteboardModel.clear();
		}
		
		private function handleUndoCommand( message:Object ):void
		{
			whiteboardModel.undo();
		}
		
		private function handleEnableWhiteboardCommand( message:Object ):void
		{
			whiteboardModel.enable( message.enabled );
		}
		
		private function handleNewAnnotationCommand( message:Object ):void
		{
			if ( message.type == undefined || message.type == null || message.type == "" )
				return;
			if ( message.id == undefined || message.id == null || message.id == "" )
				return;
			if ( message.status == undefined || message.status == null || message.status == "" )
				return;
			
			var annotation:Annotation = new Annotation( message.id, message.type, message );
			annotation.status = message.status;
			whiteboardModel.addAnnotation( annotation );
		}
		
		private function handleIsWhiteboardEnabledReply( message:Object ):void
		{
			//if (result as Boolean) modifyEnabledCallback(true);
			//LogUtil.debug( "Whiteboard Enabled? " + message.enabled );
		}
		
		private function handleRequestAnnotationHistoryReply( message:Object ):void
		{
			trace( "handleRequestAnnotationHistoryReply: Annotation history for [" + message.presentationID + "," + message.pageNumber + "]" );
			if ( message.count == 0 )
			{
				trace( "handleRequestAnnotationHistoryReply: No annotations." );
			}
			else
			{
				trace( "handleRequestAnnotationHistoryReply: Number of annotations in history = " + message.count );
				var annotations:Array = message.annotations as Array;
				var tempAnnotations:Array = new Array();
				
				for ( var i:int = 0; i < message.count; i++ )
				{
					var an:Object = annotations[ i ] as Object;
					
					if ( an.type == undefined || an.type == null || an.type == "" )
						return;
					if ( an.id == undefined || an.id == null || an.id == "" )
						return;
					if ( an.status == undefined || an.status == null || an.status == "" )
						return;
					
					trace( "handleRequestAnnotationHistoryReply: annotation id=" + an.id );
					
					var annotation:Annotation = new Annotation( an.id, an.type, an );
					annotation.status = an.status;
					tempAnnotations.push( annotation );
				}
				
				if ( tempAnnotations.length > 0 )
				{
					whiteboardModel.addAnnotationFromHistory( message.presentationID, message.pageNumber, tempAnnotations );
				}
			}
		}
	}
}