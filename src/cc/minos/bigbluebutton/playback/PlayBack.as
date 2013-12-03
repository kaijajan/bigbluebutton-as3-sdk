package cc.minos.bigbluebutton.playback
{
	import adobe.utils.CustomActions;
	import cc.minos.bigbluebutton.playback.svg.*;
	import com.greensock.events.TweenEvent;
	import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import svgparser.parser.Constants;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class PlayBack extends Sprite
	{
		private var svg:XML;
		
		private var timeline:TimelineMax;
		
		private var images:Vector.<SVGImage>;
		
		private var imageCanvas:Sprite;
		
		public function PlayBack()
		{
			timeline = new TimelineMax({ paused: true } );
			//timeline.autoRemoveChildren = true;
			timeline.addEventListener( TweenEvent.UPDATE, onUpdateListener );
			timeline.addEventListener( TweenEvent.START, onStartListener );
			timeline.addEventListener( TweenEvent.COMPLETE, onCompleteListener );
			
			//images = 
			
			imageCanvas = new Sprite()
			addChild( imageCanvas );
		}
		
		private function onCompleteListener( e:TweenEvent ):void
		{
		
		}
		
		private function onStartListener( e:TweenEvent ):void
		{
		
		}
		
		private function onUpdateListener( e:TweenEvent ):void
		{
		}
		
		public function loadURL( url:String ):void
		{
			var loader:URLLoader = new URLLoader( new URLRequest( url ) );
			loader.addEventListener( Event.COMPLETE, onSVGComplte );
		}
		
		private function onSVGComplte( e:Event ):void
		{
			var xml:XML = new XML( e.currentTarget.data );
			parse( xml );
		}
		
		public function parse( xml:XML ):void
		{
			XML.ignoreWhitespace = false;
			xml.removeNamespace( Constants.svg );
			xml.removeNamespace( Constants.xlink );
			
			var ns:Namespace = Constants.svg;
			var ilist:XMLList = xml.ns::image;
			
			if ( ilist.length() <= 0 )
			{
				return;
			}
			for each ( var item:XML in ilist )
			{
				addImage( item , xml.ns::g.(@image==item.@id));
			}
		}
		
		public function addImage( xml:XML , drawXML:XMLList ):void
		{
			if ( xml.localName() == "image" )
			{
				var im:SVGImage = new SVGImage();
				im.parse( xml , drawXML );
				im.addToTimeline( timeline );
			}
		}
	
	}

}