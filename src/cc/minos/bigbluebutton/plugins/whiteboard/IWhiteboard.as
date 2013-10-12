package cc.minos.bigbluebutton.plugins.whiteboard
{
	import cc.minos.bigbluebutton.plugins.whiteboard.models.Annotation;
	import cc.minos.bigbluebutton.plugins.whiteboard.shapes.DrawAnnotation;
	import flash.display.DisplayObject;
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IWhiteboard
	{
		function addRawChild( child:DisplayObject ):void;
		function removeRawChild( child:DisplayObject ):void;
		function doesContain( child:DisplayObject ):Boolean;
		function generateID():String;
		function getMouseXY():Array;
		//function sendGraphicToServer( dan:DrawAnnotation, ctrlKeyDown:Boolean = false ):void;
		function move( xpos:Number, ypos:Number ):void;
		function zoom( width:Number, height:Number ):void;
	}

}