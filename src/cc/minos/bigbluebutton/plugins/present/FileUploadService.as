package cc.minos.bigbluebutton.plugins.present
{
	import cc.minos.bigbluebutton.plugins.present.events.UploadEvent;
	import cc.minos.extensions.Base64;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class FileUploadService
	{
		private var request:URLRequest = new URLRequest();
		private var sendVars:URLVariables = new URLVariables();
		private var plugin:PresentPlugin;
		private var fileToUpload:FileReference;
		
		public function FileUploadService( plugin:PresentPlugin, url:String, conference:String, room:String ):void
		{
			this.plugin = plugin;
			sendVars.conference = conference;
			sendVars.room = room;
			//sendVars.
			request.url = url;
			request.data = sendVars;
			//request.contentType
		}
		
		public function upload( presentationName:String, file:FileReference ):void
		{
			
			//base
			sendVars.presentation_name = presentationName;
			
			fileToUpload = file;
			fileToUpload.addEventListener( ProgressEvent.PROGRESS, onUploadProgress );
			fileToUpload.addEventListener( Event.COMPLETE, onUploadComplete );
			fileToUpload.addEventListener( IOErrorEvent.IO_ERROR, onUploadIoError );
			fileToUpload.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError );
			fileToUpload.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
			fileToUpload.addEventListener( Event.OPEN, openHandler );
			
			request.method = URLRequestMethod.POST;
			
			// "fileUpload" is the variable name of the uploaded file in the server
			fileToUpload.upload( request, "fileUpload", true );
		}
		
		private function onUploadProgress( e:ProgressEvent ):void
		{
			var percentage:Number = Math.round(( e.bytesLoaded / e.bytesTotal ) * 100 );
			var uploadEvent:UploadEvent = new UploadEvent( UploadEvent.UPLOAD_PROGRESS_UPDATE );
			uploadEvent.percentageComplete = percentage;
			plugin.dispatchEvent( uploadEvent );
		}
		
		private function onUploadComplete( e:Event ):void
		{
			plugin.dispatchEvent( new UploadEvent( UploadEvent.UPLOAD_COMPLETE ) );
		}
		
		private function onUploadIoError( e:IOErrorEvent ):void
		{
			plugin.dispatchEvent( new UploadEvent( UploadEvent.UPLOAD_IO_ERROR ) );
		}
		
		private function onUploadSecurityError( e:SecurityErrorEvent ):void
		{
			plugin.dispatchEvent( new UploadEvent( UploadEvent.UPLOAD_SECURITY_ERROR ) );
		}
		
		private function httpStatusHandler( e:HTTPStatusEvent ):void
		{
		}
		
		private function openHandler( e:Event ):void
		{
		}
	
	}

}