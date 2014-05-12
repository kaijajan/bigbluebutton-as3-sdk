package cc.minos.bigbluebutton.plugins.present
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	/**
	 * 文檔頁面
	 */
	public class Slide
	{
		private var _loader:URLLoader;
		private var _loaded:Boolean = false;
		private var _slideUri:String;
		private var _slideLoadedHandler:Function;
		//private var /*_slideProgressHandler*/:Function;
		
		private var _slideNum:Number;
		private var _thumbUri:String;
		private var _txtUri:String;
		
		public function Slide( slideNum:Number, slideUri:String, thumbUri:String, txtUri:String )
		{
			_slideNum = slideNum;
			_slideUri = slideUri;
			_thumbUri = thumbUri;
			_txtUri = txtUri;
			_loader = new URLLoader();
			_loader.addEventListener( Event.COMPLETE, handleComplete );
			_loader.addEventListener( ProgressEvent.PROGRESS, handleProgress );
			_loader.addEventListener( IOErrorEvent.IO_ERROR, handlerIoError );
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
		}
		
		private function handlerIoError(e:IOErrorEvent):void 
		{
			trace(e);
		}
		
		public function load( slideLoadedHandler:Function ):void
		{
			if ( _loaded && slideLoadedHandler != null )
			{
				slideLoadedHandler( _slideNum, _loader.data );
			}
			else
			{
				_slideLoadedHandler = slideLoadedHandler;
				_loader.load( new URLRequest( _slideUri ) );
			}
		}
		
		private function handleProgress( e:ProgressEvent ):void
		{
			//trace( e.bytesLoaded / e.bytesTotal );
		}
		
		private function handleComplete( e:Event ):void
		{
			_loaded = true;
			if ( _slideLoadedHandler != null )
			{
				_slideLoadedHandler( _slideNum, _loader.data );
			}
		}
		
		public function get thumb():String
		{
			return _thumbUri;
		}
		
		public function get slideNumber():Number
		{
			return _slideNum;
		}
	
	}
}