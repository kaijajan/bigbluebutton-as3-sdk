package cc.minos.bigbluebutton.plugins.present
{
	import cc.minos.bigbluebutton.events.UploadEvent;
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
	public class FileUploadService extends EventDispatcher
	{
		private var request:URLRequest = new URLRequest();
		private var sendVars:URLVariables = new URLVariables();
		private var fileToUpload:FileReference;

		public function FileUploadService()
		{
		}

		public function upload( url:String, name:String, file:FileReference, conference:String, room:String ):void
		{
			sendVars.presentation_name = name;
			sendVars.conference = conference;
			sendVars.room = room;
			request.url = url;
			request.data = sendVars;

			fileToUpload = file;
			fileToUpload.addEventListener( ProgressEvent.PROGRESS, onUploadProgress );
			fileToUpload.addEventListener( Event.COMPLETE, onUploadComplete );
			fileToUpload.addEventListener( IOErrorEvent.IO_ERROR, onUploadIoError );
			fileToUpload.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError );

			request.method = URLRequestMethod.POST;

            try{
			     fileToUpload.upload( request, "fileUpload", true );
             }catch(e:Error)
             {
                trace("upload file error: " + e.message );
             }
		}

		private function onUploadProgress( e:ProgressEvent ):void
		{
			var percentage:Number = Math.round(( e.bytesLoaded / e.bytesTotal ) * 100 );
			var uploadEvent:UploadEvent = new UploadEvent( UploadEvent.UPLOAD_PROGRESS_UPDATE );
			uploadEvent.percentageComplete = percentage;
			dispatchEvent( uploadEvent );
		}

		private function onUploadComplete( e:Event ):void
		{
			dispatchEvent( new UploadEvent( UploadEvent.UPLOAD_COMPLETE ) );
		}

		private function onUploadIoError( e:IOErrorEvent ):void
		{
			dispatchEvent( new UploadEvent( UploadEvent.UPLOAD_IO_ERROR ) );
		}

		private function onUploadSecurityError( e:SecurityErrorEvent ):void
		{
			dispatchEvent( new UploadEvent( UploadEvent.UPLOAD_SECURITY_ERROR ) );
		}

	}
}