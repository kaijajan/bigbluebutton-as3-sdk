package cc.minos.bigbluebutton.plugins.whiteboard
{
	import cc.minos.bigbluebutton.plugins.whiteboard.models.Annotation;
	import cc.minos.bigbluebutton.plugins.whiteboard.shapes.DrawAnnotation;
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IWhiteboard
	{
		function generateID():String;
		function getMouseXY():Array;
		function sendGraphicToServer( dan:DrawAnnotation, ctrlKeyDown:Boolean = false ):void;
		function move( xpos:Number, ypos:Number ):void;
		function zoom( width:Number, height:Number ):void;
	}

}