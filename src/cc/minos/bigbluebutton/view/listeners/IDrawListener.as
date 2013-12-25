package cc.minos.bigbluebutton.view.listeners
{
	import cc.minos.bigbluebutton.view.models.WhiteboardTool;
	
	public interface IDrawListener
	{
		function onMouseDown( mouseX:Number, mouseY:Number, tool:WhiteboardTool ):void;
		function onMouseMove( mouseX:Number, mouseY:Number, tool:WhiteboardTool ):void;
		function onMouseUp( mouseX:Number, mouseY:Number, tool:WhiteboardTool ):void;
		function ctrlKeyDown( down:Boolean ):void;
	}
}