
package cc.minos.bigbluebutton.plugins.present
{
	import cc.minos.bigbluebutton.core.BaseSOService;
	import flash.net.NetConnection;
	
	/**
	 * ...
	 * @author Minos
	 */
	public class PresentSOService extends BaseSOService
	{
		
		public function PresentSOService( client:IPresentSOServiceClient )
		{
			super( client );
			soName = "presentationSO";
		}
		
		public function setProperty( propertyName:String, value:Object = null ):void
		{
			sharedObject.setProperty( propertyName, value );
		}
		
		public function resizeSlide( size:Number ):void
		{
			sharedObject.send( "resizeSlideCallback", size );
		}
		
		public function queryPresenterForSlideInfo( userID:String ):void
		{
			sharedObject.send( "whatIsTheSlideInfo", userID );
		}
		
		public function whatIsTheSlideInfo( userID:String, xOffset:Number, yOffset:Number, widthRatio:Number, heightRatio:Number ):void
		{
			sharedObject.send( "whatIsTheSlideInfoCallback", userID, xOffset, yOffset, widthRatio, heightRatio );
		}
		
		public function maximize():void
		{
			sharedObject.send( "maximizeCallback" );
		}
		
		public function restore():void
		{
			sharedObject.send( "restoreCallback" );
		}
		
		public function clearPresentation():void
		{
			sharedObject.send( "clearCallback" );
		}
	
	}
}