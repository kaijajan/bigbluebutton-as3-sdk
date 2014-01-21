package cc.minos.bigbluebutton.playback
{
	import adobe.utils.CustomActions;
	import cc.minos.bigbluebutton.playback.events.CursorEvent;
	import cc.minos.bigbluebutton.playback.events.PlayBackEvent;
	import cc.minos.bigbluebutton.playback.events.ZoomEvent;
	import cc.minos.bigbluebutton.playback.steps.ChatStep;
	import cc.minos.bigbluebutton.playback.steps.CursorStep;
	import cc.minos.bigbluebutton.playback.steps.ImageElement;
	import cc.minos.bigbluebutton.playback.steps.IStep;
	import cc.minos.bigbluebutton.playback.steps.ZoomStep;
	import cc.minos.bigbluebutton.playback.style.Style;
	import cc.minos.bigbluebutton.playback.utils.StyleUtil;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class PlayBack extends Sprite implements IPlayBack
	{
		private var host:String = "http://fd.tt.gzedu.com";
		private var files:Array = [ "cursor.xml", "metadata.xml", "panzooms.xml", "shapes.svg", "slides_new.xml" ];
		private var xmls:Dictionary;
		private var recordings:String = "/presentation/";
		private var url:String;
		private var id:String;
		
		private var timer:Timer;
		private var steps:Vector.<IStep>;
		private var images:Vector.<ImageElement>;
		
		private var _time:Number = 0;
		private var _totalTime:Number = 0;
		
		public var isReady:Boolean = false;
		
		private var canvas:Sprite;
		private var _currentImage:ImageElement;
		
		private var cursor:CursorShape;
		private var infoTf:TextField;
		private var border:Shape;
		
		private var cursorStep:CursorStep;
		private var zoomStep:ZoomStep;
		
		private var _width:Number = 1;
		private var _height:Number = 1;
		
		private var scale:Number = 1;
		
		public function PlayBack( host:String )
		{
			if ( host.indexOf( "http://" ) != 0 && host.indexOf( "https://" ) != 0 )
			{
				host = "http://" + host;
			}
			this.host = host;
			xmls = new Dictionary();
		}
		
		private function initPB():void
		{
			timer = new Timer( 100, 0 );
			timer.addEventListener( TimerEvent.TIMER, onTimer );
			
			steps = new Vector.<IStep>();
			images = new Vector.<ImageElement>();
			
			addChild( canvas = new Sprite() );
			addChild( cursor = new CursorShape() );
			
			infoTf = new TextField();
			infoTf.defaultTextFormat = new TextFormat( "Consolas", 12, 0xcc0000, true );
			infoTf.autoSize = "left";
			addChild( infoTf );
			
			//event step
			steps.push( cursorStep = new CursorStep( xmls[ "cursor.xml" ] ) );
			steps.push( zoomStep = new ZoomStep( xmls[ "panzooms.xml" ] ) );
			steps.push( new ChatStep( xmls[ "slides_new.xml" ] ) );
			
			zoomStep.addEventListener( ZoomEvent.ZOOM, onZoom );
			cursorStep.addEventListener( CursorEvent.UPDATE, onCursor );
			
			//images
			//var url:String = host + recordings + id + "/";
			var xml:XML = xmls[ "shapes.svg" ];
			var ns:Namespace = Constants.svg;
			
			var style:Array = xml.@style.toString().split( " " );
			
			for ( var i:int = 0; i < style.length; i++ )
			{
				var ss:Array = String( style[ i ] ).replace( ";", "" ).split( ":" );
				if ( ss.length < 2 )
					break;
				
				if ( this.hasOwnProperty( ss[ 0 ] ) )
				{
					this[ ss[ 0 ] ] = StyleUtil.toNumber( ss[ 1 ] );
				}
			}
			
			this.graphics.beginFill( 0x00aa00, .1 );
			this.graphics.drawRect( 0, 0, width, height );
			this.graphics.endFill();
			
			border = new Shape();
			addChild( border );
			border.graphics.lineStyle( 1, 0, 1 );
			border.graphics.drawRect(0, 0, this.width, this.height);
			
			
			for each ( var ix:XML in xml.ns::image )
			{
				var image:ImageElement = new ImageElement( url, ix );
				images.push( image );
			}
			
			_totalTime = images[images.length - 1].outTime;
			
			hideCursor();
			
			trace( "images: " + images.length );
			trace( 'playback is ready!!' );
			isReady = true;
			
			sendPlayBackEvent( PlayBackEvent.READY );
		}
		
		private function hideCursor():void 
		{
			cursor.visible = false;
		}
		
		private function showCursor():void
		{
			cursor.visible = true;
		}
		
		private function onCursor( e:CursorEvent ):void
		{
			showCursor();
			cursor.x = canvas.x + e.x;
			cursor.y = canvas.y + e.y;
		}
		
		private function onZoom( e:ZoomEvent ):void
		{
			//trace( e );
			if ( currentImage != null )
			{
				var matrix:Matrix = new Matrix( ( currentImage.imageWidth / e.width ) * scale, 0, 0, ( currentImage.imageHeight / e.height ) * scale , -e.x * scale, -e.y * scale );
				currentImage.transform.matrix = matrix;
			}
		}
		
		private function onTimer( e:TimerEvent ):void
		{
			time = timer.currentCount / 10;
		}
		
		private function setStep():void
		{
			infoTf.text = time.toString();
			if ( steps.length > 0 )
			{
				for each ( var s:IStep in steps )
				{
					if ( s.inRange( time ) )
					{
						s.step( time );
					}
					else if ( s.type == "image" )
					{
					}
				}
				
				if ( currentImage == null || !currentImage.inRange( time ) )
				{
					currentImage = getImageByTime( time );
				}
				
				if ( currentImage != null )
				{
					currentImage.step( time );
				}
			}
		}
		
		private function getImageByTime( time:Number ):ImageElement
		{
			for each ( var item:ImageElement in images )
			{
				if ( item.inRange( time ) )
					return item;
			}
			return null;
		}
		
		/* INTERFACE cc.minos.bigbluebutton.playback.IPlayBack */
		
		public function loadMeeting( id:String ):void
		{
			this.id = id;
			this.url = host + recordings + id + "/";
			
			var fileName:String;
			var xmlloader:XMLLoader
			for ( var i:int = 0; i < files.length; i++ )
			{
				fileName = files[ i ];
				xmlloader = new XMLLoader();
				xmlloader.id = fileName;
				xmlloader.load( url + fileName );
				xmlloader.addEventListener( Event.COMPLETE, onXMLLoaderComplete );
			}
		}
		
		private function onXMLLoaderComplete( e:Event ):void
		{
			//check id and add to dic..
			var loader:XMLLoader = e.currentTarget as XMLLoader;
			loader.removeEventListener( Event.COMPLETE, onXMLLoaderComplete );
			xmls[ loader.id ] = loader.xml;
			
			trace( loader.id + " completed." );
			
			//check ready and send event^
			for ( var i:int = 0; i < files.length; i++ )
			{
				if ( xmls[ files[ i ] ] == undefined )
					return;
			}
			
			initPB();
		}
		
		public function play():void
		{
			if ( isReady )
			{
				timer.start();
				sendPlayBackEvent( PlayBackEvent.PLAY );
			}
		}
		
		public function stop():void
		{
			timer.stop();
			timer.reset();
			time = 0;
			sendPlayBackEvent( PlayBackEvent.STOP );
		}
		
		public function pause():void
		{
			timer.stop();
			sendPlayBackEvent( PlayBackEvent.PAUSE );
		}
		
		public function clear():void
		{
			stop();
			//clear all steps.
			
			
			
			
			sendPlayBackEvent( PlayBackEvent.CLEAR );
		}
		
		public function get time():Number
		{
			return _time;
		}
		
		public function set time( value:Number ):void
		{
			if ( value <= totalTime )
			{
				_time = value;
				setStep();
				sendPlayBackEvent( PlayBackEvent.UPDATE );
			}else
			{
				stop();
			}
		}
		
		public function get totalTime():Number
		{
			return _totalTime;
		}
		
		public function get currentImage():ImageElement
		{
			return _currentImage;
		}
		
		public function set currentImage( value:ImageElement ):void
		{
			if ( value != null )
			{
				while ( canvas.numChildren > 0 )
				{
					canvas.removeChildAt( 0 );
				}
			}
			_currentImage = value;
			if ( _currentImage != null )
			{
				canvas.addChild( _currentImage );
				
				if ( currentImage.imageWidth > currentImage.imageHeight )
				{
					scale = ( this.width / currentImage.imageWidth );
				}else {
					scale = ( this.height / currentImage.imageHeight );
				}
				
				var matrix:Matrix = new Matrix( scale, 0, 0, scale , 0, 0 );
				currentImage.transform.matrix = matrix;
				
			}
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function set width( value:Number ):void
		{
			_width = value;
		}
		
		override public function get height():Number
		{
			return _height;
		}
		
		override public function set height( value:Number ):void
		{
			_height = value;
		}
		
		private function sendPlayBackEvent( type:String ):void
		{
			var readyEvent:PlayBackEvent = new PlayBackEvent( type );
			readyEvent.id = this.id;
			dispatchEvent( readyEvent );
		}
	}

}