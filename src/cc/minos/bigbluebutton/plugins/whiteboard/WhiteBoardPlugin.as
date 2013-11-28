package cc.minos.bigbluebutton.plugins.whiteboard
{
	import cc.minos.bigbluebutton.IMessageListener;
	import cc.minos.bigbluebutton.plugins.Plugin;
	import cc.minos.bigbluebutton.plugins.present.events.NavigationEvent;
	import cc.minos.bigbluebutton.plugins.present.events.PresentationEvent;
	import cc.minos.bigbluebutton.plugins.present.PresentPlugin;
	import cc.minos.bigbluebutton.plugins.whiteboard.models.*;
	import cc.minos.bigbluebutton.plugins.whiteboard.shapes.DrawAnnotation;
	import cc.minos.console.Console;
	import flash.net.Responder;
	
	/**
	 * 白板應用
	 * @author Minos
	 */
	public class WhiteBoardPlugin extends Plugin implements IMessageListener
	{
		private static const SET_ACTIVE_PAGE:String = "whiteboard.setActivePage";
		private static const TOGGLE_GRID:String = "whiteboard.toggleGrid";
		private static const UNDO:String = "whiteboard.undo";
		private static const CLEAR:String = "whiteboard.clear";
		private static const REQUEST_ANNOTATION_HISTORY:String = "whiteboard.requestAnnotationHistory";
		private static const SEND_ANNOTATION:String = "whiteboard.sendAnnotation";
		private static const IS_WHITEBOARD_ENABLED:String = "whiteboard.isWhiteboardEnabled";
		private static const SET_ACTIVE_PRESENTATION:String = "whiteboard.setActivePresentation";
		
		public var whiteboardModel:WhiteboardModel;
		private var presentPlugin:PresentPlugin;
		//private var responder:Responder;
		
		public function WhiteBoardPlugin()
		{
			super();
			this.name = "[WhiteBoardPlugin]";
			this.shortcut = "board";
		}
		
		override protected function init():void
		{
			super.init();
			
			//responder = new Responder( //
				//function( result:String ):void
				//{
				//}, function( status:String ):void
				//{
				//} );
				
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
				bbb.send( [REQUEST_ANNOTATION_HISTORY , responder , { presentationID: cp.presentationID, pageNumber: cp.currentPageNumber }] );
			}
		}
		
		public function modifyEnabled( enabled:Boolean ):void
		{
			bbb.send( [ TOGGLE_GRID, responder, { enabled: enabled } ] );
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
				bbb.send( [ SET_ACTIVE_PAGE, responder, { pageNum: pageNum } ] );
			}
			else
			{
				whiteboardModel.changePage( pageNum, 0 );
			}
		}
		
		public function toggleGrid():void
		{
			bbb.send( [ TOGGLE_GRID, responder ] );
		}
		
		public function undoGraphic():void
		{
			bbb.send( [ UNDO, responder ]);
		}
		
		public function clearBoard():void
		{
			bbb.send( [ CLEAR, responder ] );
		}
		
		public function sendAnnotation( annotation:Annotation ):void
		{
			bbb.send( [ SEND_ANNOTATION, responder, annotation.annotation ] );
		}
		
		public function checkIsWhiteboardOn():void
		{
			bbb.send( [ IS_WHITEBOARD_ENABLED, responder ] );
		}
		
		public function setActivePresentation( presentationName:String, numberOfPages:int ):void
		{
			if ( presenter )
			{
				bbb.send( [ SET_ACTIVE_PRESENTATION, responder, { presentationID: presentationName, numberOfSlides: numberOfPages } ] );
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