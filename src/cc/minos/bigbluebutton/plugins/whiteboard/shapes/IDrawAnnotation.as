package cc.minos.bigbluebutton.plugins.whiteboard.shapes
{
	import cc.minos.bigbluebutton.plugins.whiteboard.models.Annotation;
	import cc.minos.bigbluebutton.plugins.whiteboard.models.WhiteboardModel;
	
	public interface IDrawAnnotation
	{
		function createAnnotation( wbModel:WhiteboardModel, ctrlKeyPressed:Boolean = false ):Annotation;
	}
}