package cc.minos.bigbluebutton.plugins
{
	import cc.minos.bigbluebutton.extensions.IMessageListener;
	import cc.minos.bigbluebutton.plugins.present.events.NavigationEvent;
	import cc.minos.bigbluebutton.plugins.whiteboard.*;
	import cc.minos.bigbluebutton.plugins.whiteboard.models.*;
	import cc.minos.console.Console;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class WhiteBoardPlugin extends Plugin implements IMessageListener
	{
		private var service:WhiteBoardService;
		
		public function WhiteBoardPlugin()
		{
			super();
			this.name = "[WhiteBoardPlugin]";
			this.shortcut = "board";
		}
		
		override public function init():void
		{
			super.init();
			
			var present:PresentPlugin = bbb.getPlugin( "present" ) as PresentPlugin;
			if ( present == null )
			{
				Console.log( "", null, Console.ERROR );
				return;
			}
			
			present.addEventListener( NavigationEvent.GOTO_PAGE, onGotoPage );
			
			
			
		}
		
		public function get presenter():Boolean
		{
			return bbb.plugins[ 'users' ].getMe().presenter;
		}
		
		private function onGotoPage( e:NavigationEvent ):void
		{
			changePage( e.pageNumber );
		}
		
		public function changePage( pageNum:Number ):void
		{
			pageNum += 1;
			if ( presenter )
			{
				
			}
			else
			{
				
			}
		}
		
		public function toggleGrid():void
		{
		}
		
		public function undoGraphic():void
		{
		}
		
		public function clearBoard():void
		{
		}
		
		public function sendShape( annotation:Annotation ):void
		{
		
		}
		
		public function sendText( annotation:Annotation ):void
		{
		
		}
		
		public function setActivePresentation( presentationName:String, numberOfPages:int ):void
		{
		
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
	
	}