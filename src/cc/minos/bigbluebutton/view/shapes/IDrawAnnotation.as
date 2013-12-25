package cc.minos.bigbluebutton.view.shapes
{
	import cc.minos.bigbluebutton.models.Annotation;
	
	public interface IDrawAnnotation
	{
		function createAnnotation( ctrlKeyPressed:Boolean = false ):Annotation
	}
}