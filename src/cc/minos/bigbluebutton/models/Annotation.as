package cc.minos.bigbluebutton.models
{
	
	public class Annotation
	{
		public static const DRAW_UPDATE:String = "DRAW_UPDATE";
		public static const DRAW_END:String = "DRAW_END";
		public static const DRAW_START:String = "DRAW_START";
		
		public static const PENCIL:String = "pencil";
		public static const RECTANGLE:String = "rectangle";
		public static const ELLIPSE:String = "ellipse";
		public static const TEXT:String = "text";
		
		private var _id:String = "undefined";
		private var _status:String = Annotation.DRAW_START;
		private var _type:String = "undefined";
		private var _annotation:Object;
		private var _presentationID:String;
		private var _pageNumber:int;
		
		public function Annotation( id:String, type:String, annotation:Object )
		{
			_id = id;
			_type = type;
			_annotation = annotation;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function get annotation():Object
		{
			return _annotation;
		}
		
		public function set annotation( a:Object ):void
		{
			_annotation = a;
		}
		
		public function get status():String
		{
			return _status;
		}
		
		public function set status( s:String ):void
		{
			_status = s;
		}
		
		public function get presentationID():String
		{
			return _annotation.presentationID;
		}
		
		public function get pageNumber():Number
		{
			return _annotation.pageNumber;
		}
	}
}