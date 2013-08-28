package cc.minos.bigbluebutton.plugins.present
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class PresentationService
	{
		private var slides:Array;
		private var url:String;
		private var slideUri:String;
		private var urlLoader:URLLoader;
		
		public function PresentationService()
		{
		}
		
		public function load( url:String, slides:Array, slideUri:String ):void
		{
			this.slideUri = slideUri;
			this.url = url;
			this.slides = slides;
			
			urlLoader = new URLLoader();
			urlLoader.addEventListener( Event.COMPLETE, handleComplete );
			urlLoader.addEventListener( IOErrorEvent.IO_ERROR, handleIOErrorEvent );
			urlLoader.load( new URLRequest( url ) );
		}
		
		private function handleComplete( e:Event ):void
		{
			//trace( "Loading complete" );
			parse( new XML( e.target.data ) );
			clean();
		}
		
		private function handleIOErrorEvent( e:IOErrorEvent ):void
		{
			trace( e.toString() );
			clean();
		}
		
		private function clean():void
		{
			urlLoader.removeEventListener( Event.COMPLETE, handleComplete );
			urlLoader.removeEventListener( IOErrorEvent.IO_ERROR, handleIOErrorEvent );
			urlLoader = null;
		}
		
		public function parse( xml:XML ):void
		{
			var list:XMLList = xml.presentation.slides.slide;
			var item:XML;
			trace( "Slides: " + xml );
			
			var presentationName:String = xml.presentation[ 0 ].@name;
			trace( "PresentationService::parse()...  presentationName=" + presentationName );
			
			// Make sure we start with a clean set.
			slides.length = 0;
			
			for each ( item in list )
			{
				var sUri:String = slideUri + "/" + item.@name;
				var thumbUri:String = slideUri + "/" + item.@thumb;
				var txtUri:String = slideUri + "/" + item.@textfile;
				
				var slide:Slide = new Slide( item.@number, sUri, thumbUri, txtUri );
				slides.push( slide );
			}
			
			if ( _onCompletedListener != null )
				_onCompletedListener( presentationName, slides );
		
		}
		
		private var _onCompletedListener:Function;
		
		public function addCompleteListener( onCompletedListener:Function ):void
		{
			_onCompletedListener = onCompletedListener;
		}
		
		/**
		 * This is the response event. It is called when the PresentationService class sends a request to
		 * the server. This class then responds with this event
		 * @param event
		 *
		 */
		public function result( event:Object ):void
		{
			var xml:XML = new XML( event.result );
			var list:XMLList = xml.presentations;
			var item:XML;
			
			for each ( item in list )
			{
				trace( "Available Modules: " + item.toXMLString() + " at " + item.text() );
			}
		}
		
		/**
		 * Event is called in case the call the to server wasn't successful. This method then gets called
		 * instead of the result() method above
		 * @param event
		 *
		 */
		public function fault( event:Object ):void
		{
			trace( "Got fault [" + event.fault.toString() + "]" );
		}
	
	}

}