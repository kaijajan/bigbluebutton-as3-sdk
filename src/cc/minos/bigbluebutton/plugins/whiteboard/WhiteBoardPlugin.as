package cc.minos.bigbluebutton.plugins.whiteboard
{
	import cc.minos.bigbluebutton.core.IMessageListener;
	import cc.minos.bigbluebutton.events.NavigationEvent;
	import cc.minos.bigbluebutton.events.PresentationEvent;
	import cc.minos.bigbluebutton.events.WhiteboardDrawEvent;
	import cc.minos.bigbluebutton.models.Annotation;
	import cc.minos.bigbluebutton.plugins.Plugin;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class WhiteboardPlugin extends Plugin implements IWhiteboardPlugin, IMessageListener
	{
		private static const SET_ACTIVE_PAGE:String = "whiteboard.setActivePage";
		private static const TOGGLE_GRID:String = "whiteboard.toggleGrid";
		private static const UNDO:String = "whiteboard.undo";
		private static const CLEAR:String = "whiteboard.clear";
		private static const REQUEST_ANNOTATION_HISTORY:String = "whiteboard.requestAnnotationHistory";
		private static const SEND_ANNOTATION:String = "whiteboard.sendAnnotation";
		private static const IS_WHITEBOARD_ENABLED:String = "whiteboard.isWhiteboardEnabled";
		private static const SET_ACTIVE_PRESENTATION:String = "whiteboard.setActivePresentation";
		
		private var currentPresentationName:String;
		private var currentPageNumber:Number;
		
		public function WhiteboardPlugin()
		{
			super();
			this._name = "[WhiteboardPlugin]";
			this._shortcut = "whiteboard";
		}
		
		override public function init():void
		{
		}
		
		override public function start():void
		{
			bbb.addEventListener( PresentationEvent.PRESENTATION_LOADED, onPresentation );
			bbb.addEventListener( NavigationEvent.GOTO_PAGE, onGotoPage );
			bbb.addMessageListener( this );
		}
		
		override public function stop():void
		{
			bbb.removeEventListener( PresentationEvent.PRESENTATION_LOADED, onPresentation );
			bbb.removeEventListener( NavigationEvent.GOTO_PAGE, onGotoPage );
			bbb.removeMessageListener( this );
		}
		
		private function onPresentation( e:PresentationEvent ):void
		{
			currentPresentationName = e.presentationName;
			setActivePresentation( e.presentationName, e.slides.length );
		}
		
		private function onGotoPage( e:NavigationEvent ):void
		{
			currentPageNumber = e.pageNumber +1;
			changePage( currentPageNumber );
		}
		
		/* INTERFACE cc.minos.bigbluebutton.core.IMessageListener */
		
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
			var changeEvent:WhiteboardDrawEvent = new WhiteboardDrawEvent( WhiteboardDrawEvent.CHANGE_PRESENTATION );
			changeEvent.presentationID = message.presentationID;
			changeEvent.numberOfPages = message.numberOfPages;
			dispatchRawEvent( changeEvent );
		}
		
		private function handleChangePageCommand( message:Object ):void
		{
			var changeEvent:WhiteboardDrawEvent = new WhiteboardDrawEvent( WhiteboardDrawEvent.CHANGE_PAGE );
			changeEvent.pageNum = message.pageNum;
			changeEvent.numAnnotations = message.numAnnotations;
			dispatchRawEvent( changeEvent );
		}
		
		private function handleClearCommand( message:Object ):void
		{
			var clearEvent:WhiteboardDrawEvent = new WhiteboardDrawEvent( WhiteboardDrawEvent.CLEAR );
			dispatchRawEvent( clearEvent );
		}
		
		private function handleUndoCommand( message:Object ):void
		{
			var clearEvent:WhiteboardDrawEvent = new WhiteboardDrawEvent( WhiteboardDrawEvent.UNDO );
			dispatchRawEvent( clearEvent );
		
		}
		
		private function handleEnableWhiteboardCommand( message:Object ):void
		{
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
			
			var clearEvent:WhiteboardDrawEvent = new WhiteboardDrawEvent( WhiteboardDrawEvent.NEW_ANNOTATION );
			clearEvent.annotation = annotation;
			dispatchRawEvent( clearEvent );
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
				for ( var i:int = 0; i < message.count; i++ )
				{
					handleNewAnnotationCommand( annotations[ i ] as Object );
				}
			}
		}
		
		/* INTERFACE cc.minos.bigbluebutton.plugins.whiteboard.IWhiteboardPlugin */
		
		public function setActivePresentation( presentationName:String, numberOfPages:int ):void
		{
			if ( presenter )
			{
				bbb.send( SET_ACTIVE_PRESENTATION, null, { presentationID: presentationName, numberOfSlides: numberOfPages } );
			}
			else
			{
				var changeEvent:WhiteboardDrawEvent = new WhiteboardDrawEvent( WhiteboardDrawEvent.CHANGE_PRESENTATION );
				changeEvent.presentationID = presentationName;
				changeEvent.numberOfPages = numberOfPages;
				dispatchRawEvent( changeEvent );
			}
		}
		
		public function clearBoard():void
		{
			bbb.send( CLEAR, null );
		}
		
		public function toggleGrid():void
		{
			bbb.send( TOGGLE_GRID, null );
		}
		
		public function undoGraphic():void
		{
			bbb.send( UNDO, null );
		}
		
		public function changePage( pageNum:Number ):void
		{
			//pageNum += 1;
			if ( presenter )
			{
				bbb.send( SET_ACTIVE_PAGE, null, { pageNum: pageNum } );
			}
			else
			{
				//whiteboardModel.changePage( pageNum, 0 );
				var changeEvent:WhiteboardDrawEvent = new WhiteboardDrawEvent( WhiteboardDrawEvent.CHANGE_PAGE );
				changeEvent.pageNum = pageNum;
				changeEvent.numAnnotations = 0;
				dispatchRawEvent( changeEvent );
			}
		}
		
		public function sendAnnotation( annotation:Annotation ):void
		{
			annotation.annotation["presentationID"] = currentPresentationName;
			annotation.annotation["pageNumber"] = currentPageNumber;
			
			bbb.send( SEND_ANNOTATION, null, annotation.annotation );
		}
		
		public function checkIsWhiteboardOn():void
		{
			bbb.send( IS_WHITEBOARD_ENABLED, null );
		}
		
		public function getAnnotationHistory():void
		{
			//var cp:Object = whiteboardModel.getCurrentPresentationAndPage();
			//if ( cp != null )
			//{
			bbb.send( REQUEST_ANNOTATION_HISTORY, null, { presentationID: currentPresentationName, pageNumber: currentPageNumber } );
			//}
		}
		
		public function modifyEnabled( enabled:Boolean ):void
		{
			bbb.send( TOGGLE_GRID, null, { enabled: enabled } );
		}
	
	}

}