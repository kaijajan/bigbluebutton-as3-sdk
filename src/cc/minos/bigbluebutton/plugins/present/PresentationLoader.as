package cc.minos.bigbluebutton.plugins.present
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class PresentationLoader
	{
		private var url:String;
		private var slideUri:String;
		private var urlLoader:URLLoader;
		private var onCompletedListener:Function;
		
		public function PresentationLoader( callback:Function ):void
		{
			onCompletedListener = callback;
		}
		
		public function load( slideUri:String ):void
		{
			//this.url = url;
			this.slideUri = slideUri;
			
			urlLoader = new URLLoader();
			urlLoader.addEventListener( Event.COMPLETE, onComplete );
			urlLoader.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			urlLoader.load( new URLRequest( slideUri + "/slides" ) );
		}
		
		private function onComplete( e:Event ):void
		{
			parse( new XML( e.target.data ) );
			//clean();
		}
		
		private function onIOError( e:Event ):void
		{
			//clean();
		}
		
		private function clean():void
		{
			if ( urlLoader != null )
			{
				urlLoader.removeEventListener( Event.COMPLETE, onComplete );
				urlLoader.removeEventListener( IOErrorEvent.IO_ERROR, onIOError );
				urlLoader = null;
			}
		}
		
		public function parse( xml:XML ):void
		{
			var list:XMLList = xml.presentation.slides.slide;
			var item:XML;
			//Console.log( "Slides: " + xml );
			
			var presentationName:String = xml.presentation[ 0 ].@name;
			
			// Make sure we start with a clean set.
			var slides:Array = [];
			
			for each ( item in list )
			{
				var sUri:String = slideUri + "/" + item.@name;
				var thumbUri:String = slideUri + "/" + item.@thumb;
				var txtUri:String = slideUri + "/" + item.@textfile;
				
				var slide:Slide = new Slide( item.@number, sUri, thumbUri, txtUri );
				slides.push( slide );
			}
			
			if ( onCompletedListener != null )
				onCompletedListener( presentationName, slides );
		
		}
	
	}
}