package cc.minos.bigbluebutton.plugins.whiteboard
{
	import cc.minos.bigbluebutton.plugins.WhiteBoardPlugin;
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class WhiteBoardService
	{
		private static const SET_ACTIVE_PAGE:String = "whiteboard.setActivePage";
		private static const TOGGLE_GRID:String = "whiteboard.toggleGrid";
		private static const UNDO:String = "whiteboard.undo";
		private static const CLEAR:String = "whiteboard.clear";
		private static const REQUEST_ANNOTATION_HISTORY:String = "whiteboard.requestAnnotationHistory";
		private static const SEND_ANNOTATION:String = "whiteboard.sendAnnotation";
		private static const IS_WHITEBOARD_ENABLED:String = "whiteboard.isWhiteboardEnabled";
		private static const SET_ACTIVE_PRESENTATION:String = "whiteboard.setActivePresentation";
		
		private var plugin:WhiteBoardPlugin;
		private var connection:NetConnection;
		private var responder:Responder;
		
		public function WhiteBoardService( plugin:WhiteBoardPlugin )
		{
			this.plugin = plugin;
			connection = plugin.connection;
			responder = new Responder( //
				function( result:String ):void
				{
				}, function( status:String ):void
				{
				} );
		}
		
		public function changePage( pageNum:Number ):void
		{
			connection.call( SET_ACTIVE_PAGE, responder, { pageNum: pageNum } );
		}
		
		public function modifyEnabled( enabled:Boolean ):void
		{
			connection.call( TOGGLE_GRID, responder, { enabled: enabled } );
		}
		
		public function toggleGrid():void
		{
			connection.call( TOGGLE_GRID, responder );
		}
		
		public function undoGraphic():void
		{
			connection.call( UNDO, responder );
		}
		
		public function clearBoard():void
		{
			connection.call( CLEAR, responder );
		}
		
		public function requestAnnotationHistory( presentationID:String, pageNumber:int ):void
		{
			connection.call( REQUEST_ANNOTATION_HISTORY, responder, { presentationID: presentationID, pageNumber: pageNumber } );
		}
		
		public function sendAnnotation( annotation:Annotation ):void
		{
			connection.call( SEND_ANNOTATION, responder, annotation.annotation );
		}
		
		public function checkIsWhiteboardOn():void
		{
			connection.call( IS_WHITEBOARD_ENABLED, responder );
		}
		
		public function setActivePresentation( presentationName:String, numberOfPages:int ):void
		{
			connection.call( SET_ACTIVE_PRESENTATION, responder, { presentationName: presentationName, numberOfPages: numberOfPages } );
		}
	
	}

}