package cc.minos.bigbluebutton.playback.utils 
{
	public class StyleUtil
	{
		
		public static function toNumber( val:String ):Number {
			if ( val.indexOf("%") != -1 ) return Number( val.replace( /%/, "") ) / 100;
			return Number( val.replace(/%|mm|px/, ""));
		}
		
		public static function toColor( val:String ):uint 
		{
			if ( val.lastIndexOf( "rgb" ) != -1 ) {
				var vals:Array = val.replace(/rgb\((.+)\)/, "$1" ).split(",");
				var result:String = "";
				for each( var item:String in vals ) {
					var v:String = int( item  ).toString(16);
					result += ( val.length > 1 ) ? v : "0" + v;
				}
				return uint( "0x" + result );
			}
			return uint( val.replace( /#/, "0x" ) );
		}
		
		public static function toURL( val:String ):String 
		{
			return val.replace(/url\(#(.+)\)/ , "$1" );
		}
		
		public static function removeNameSpace( val:String ):String 
		{
			return val.replace(/http(.+)::(.+)/, "$2");
		}
		
		
		
	}

}