

package cc.minos.bbb.plugins.voice
{
	import cc.minos.bbb.plugins.Plugin;
	import flash.media.Microphone;
	import flash.net.NetStream;

	/**
	 * ...
	 * @author Minos
	 */
	public class VoicePlugin extends Plugin
	{
		///////////////////////
		// PROPERTIES
		///////////////////////
		
		/**
		 * portTestUpdate
		 */
		private var playStreamName:String;
		/**
		 * portTestUpdate
		 */
		private var publishStreamName:String;
		/**
		 * portTestUpdate
		 */
		private var mic:Microphone;
		/**
		 * portTestUpdate
		 */
		private var incomingStream:NetStream;
		/**
		 * portTestUpdate
		 */
		private var outgoingStream:NetStream;
		private var audioCodec:string;
		private var muted:Boolean;

		///////////////////////
		// METHODS
		///////////////////////
		
		public function join(voiceid:String):void
		{
			//TODO
		}

		public function left():void
		{
			//TODO
		}

	}
}