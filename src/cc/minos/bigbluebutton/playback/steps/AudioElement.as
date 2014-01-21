package cc.minos.bigbluebutton.playback.steps
{
	
	/**
	 * ...
	 * @author Minos
	 */
	public class AudioElement implements IElement, IStep
	{
		private var _type:String = "audio";
		
		public function AudioElement()
		{
		
		}
		
		/* INTERFACE cc.minos.bigbluebutton.playback.steps.IStep */
		
		public function get type():String
		{
			return _type;
		}
		
		public function set type( value:String ):void
		{
			_type = value;
		}
		
		public function get id():String
		{
			return "undefined";
		}
		
		public function set id( value:String ):void
		{
		}
		
		public function get inTime():Number
		{
			return -1;
		}
		
		public function set inTime( value:Number ):void
		{
		}
		
		public function get outTime():Number
		{
			return -1;
		}
		
		public function set outTime( value:Number ):void
		{
		}
		
		public function inRange( time:Number ):Boolean
		{
			return true;
		}
		
		public function step( time:Number ):void
		{
		}
		
		public function set xml( value:XML ):void
		{
		}
		
		public function get xml():XML
		{
			return null;
		}
	
	}

}