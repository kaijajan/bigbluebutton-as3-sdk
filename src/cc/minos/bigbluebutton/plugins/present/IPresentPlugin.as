package cc.minos.bigbluebutton.plugins.present
{
	import cc.minos.bigbluebutton.plugins.IPlugin;
	import flash.net.FileReference;
	
	/**
	 * ...
	 * @author Minos
	 */
	public interface IPresentPlugin extends IPlugin
	{
		function upload( file:FileReference ):void
		function loadPresentation( presentationName:String ):void
		function removePresentation( name:String ):void
		function gotoSlide( num:Number ):void
		function resizeSlide( size:Number ):void
		function updateSlide( xOffset:Number, yOffset:Number, widthRatio:Number, heightRatio:Number ):void
		function sendCursorUpdate( xPercent:Number, yPercent:Number ):void
	}

}