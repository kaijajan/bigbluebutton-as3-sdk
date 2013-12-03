package cc.minos.bigbluebutton.playback.svg
{
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.Event;
	import svgparser.parser.Constants;
	import svgparser.parser.Group;
	import svgparser.parser.Image;
	import svgparser.parser.model.Data;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class SVGImage extends Sprite
	{
		
		protected var tween:TweenLite;
		protected var inTime:Number;
		protected var outTime:Number;
		
		protected var data:XML;
		
		protected var imageContainer:Sprite;
		protected var drawContainer:Sprite;
		
		protected var image:Image;
		
		public function SVGImage( xml:XML = null )
		{
			if ( xml != null )
				parse( xml );
		
			//addEventListener( Event.ADDED_TO_STAGE, onAdded );
		}
		
		/*private function onAdded( e:Event ):void
		   {
		   removeEventListener( Event.ADDED_TO_STAGE, onAdded );
		   addEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
		   }
		
		   private function onRemoved( e:Event ):void
		   {
		   removeEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
		   addEventListener( Event.ADDED_TO_STAGE, onAdded );
		 }*/
		
		public function parse( xml:XML, drawXML:XMLList = null ):void
		{
			
			inTime = Number( xml.@[ "in" ] );
			outTime = Number( xml.@[ "out" ] );
			
			imageContainer = new Sprite();
			addChild( imageContainer );
			
			var data:Data = new Data( xml, imageContainer );
			image = new Image();
			image.parse( data );
			
			if ( drawXML != null )
			{
				drawContainer = new Sprite();
				addChild( drawContainer );
				
				for each ( var item:XML in drawXML )
				{
					delete item.@display;
					data = new Data( item, drawContainer );
					new Group().parse( data );
				}
				
			}
		}
		
		public function addToTimeline( timeline:TimelineLite ):void
		{
			tween = new TweenLite( this, 1, {} );
		}
	
	}

}