package cc.minos.bigbluebutton.plugins
{
	import cc.minos.bigbluebutton.extensions.IMessageListener;
	import cc.minos.bigbluebutton.plugins.present.events.NavigationEvent;
	import cc.minos.bigbluebutton.plugins.whiteboard.*;
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
		private var whiteboardModel:WhiteboardModel;
		private var presentPlugin:PresentPlugin;
		
		public function WhiteBoardPlugin()
		{
			super();
			this.name = "[WhiteBoardPlugin]";
			this.shortcut = "board";
		}
		
		override public function init():void
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
			
			presentPlugin.addEventListener( NavigationEvent.GOTO_PAGE, onGotoPage );
		}
		
		/**
		 * 是否演講者
		 */
		public function get presenter():Boolean
		{
			return bbb.plugins[ 'users' ].getMe().presenter;
		}
		
		private var count:uint = 0;
		public function generateID():String
		{
			var curTime:Number = new Date().getTime();
			return bbb.conferenceParameters.userID + "-" + count++ + "-" + curTime;
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
		
		public function sendAnnotation( dan:DrawAnnotation, ctrlKeyDown:Boolean ):void
		{
			var annotation:Annotation = dan.createAnnotation( whiteboardModel, ctrlKeyDown );
			if ( annotation != null )
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
			// LogUtil.debug("Handle Whiteboard Change Presentation Command [ " + message.presentationID + ", " + message.numberOfPages + "]");
			whiteboardModel.changePresentation( message.presentationID, message.numberOfPages );
		}
		
		private function handleChangePageCommand( message:Object ):void
		{
			// LogUtil.debug("Handle Whiteboard Change Page Command [ " + message.pageNum + ", " + message.numAnnotations + "]");
			whiteboardModel.changePage( message.pageNum, message.numAnnotations );
		}
		
		private function handleClearCommand( message:Object ):void
		{
			// LogUtil.debug("Handle Whiteboard Clear Command ");
			whiteboardModel.clear();
		}
		
		private function handleUndoCommand( message:Object ):void
		{
			// LogUtil.debug("Handle Whiteboard Undo Command ");
			whiteboardModel.undo();
			//            dispatcher.dispatchEvent(new WhiteboardUpdate(WhiteboardUpdate.SHAPE_UNDONE));
		}
		
		private function handleEnableWhiteboardCommand( message:Object ):void
		{
			//if (result as Boolean) modifyEnabledCallback(true);
			// LogUtil.debug("Handle Whiteboard Enabled Command " + message.enabled);
			whiteboardModel.enable( message.enabled );
		}
		
		private function handleNewAnnotationCommand( message:Object ):void
		{
			// LogUtil.debug("Handle new annotation[" + message.type + ", " + message.id + ", " + message.status + "]");
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
			//LogUtil.debug("handleRequestAnnotationHistoryReply: Annotation history for [" + message.presentationID + "," + message.pageNumber + "]");
			if ( message.count == 0 )
			{
				//LogUtil.debug( "handleRequestAnnotationHistoryReply: No annotations." );
			}
			else
			{
				//LogUtil.debug( "handleRequestAnnotationHistoryReply: Number of annotations in history = " + message.count );
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
					
					//LogUtil.debug("handleRequestAnnotationHistoryReply: annotation id=" + an.id);
					
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