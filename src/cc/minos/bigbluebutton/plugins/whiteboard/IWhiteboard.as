package cc.minos.bigbluebutton.plugins.whiteboard
{
	import cc.minos.bigbluebutton.plugins.whiteboard.models.Annotation;
	import cc.minos.bigbluebutton.plugins.whiteboard.shapes.DrawAnnotation;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IWhiteboard extends IEventDispatcher
	{
		function acceptOverlayCanvas( canvas:* ):void;
		function addRawChild( child:DisplayObject ):void;
		function removeRawChild( child:DisplayObject ):void;
		function doesContain( child:DisplayObject ):Boolean;
		function generateID():String;
		function getMouseXY():Array;
		
		function move( xpos:Number, ypos:Number ):void;
		function zoom( width:Number, height:Number ):void;
		
		//
		function addGraphic( child:DisplayObject ):void
		function removeGraphic( child:DisplayObject ):void
		function get stage():flash.display.Stage;
		function get isPresenter():Boolean;
		function queryForAnnotationHistory():void;
		function sendGraphicToServer( gobj:Annotation, type:String ):void
	
	}

}