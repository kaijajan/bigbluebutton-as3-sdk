package cc.minos.bigbluebutton.plugins.whiteboard
{
	import cc.minos.bigbluebutton.models.Annotation;
	import cc.minos.bigbluebutton.plugins.IPlugin;
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IWhiteboardPlugin extends IPlugin
	{
		function setActivePresentation( presentationName:String, numberOfPages:int ):void
		
		function clearBoard():void
		function toggleGrid():void
		function undoGraphic():void
		function changePage( pageNum:Number ):void
		function sendAnnotation( annotation:Annotation ):void
		function checkIsWhiteboardOn():void
		
		function getAnnotationHistory( ):void
		function modifyEnabled( enabled:Boolean ):void
	
	}

}