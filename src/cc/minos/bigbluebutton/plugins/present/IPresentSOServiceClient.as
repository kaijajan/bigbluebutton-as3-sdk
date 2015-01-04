package cc.minos.bigbluebutton.plugins.present {

    /**
     * ...
     * @author Minos
     */
    public interface IPresentSOServiceClient {

        ///////////////////////
        // METHODS
        ///////////////////////

        function zoomCallback(xOffset:Number, yOffset:Number, widthRatio:Number, heightRatio:Number):void;

        function resizeSlideCallback(size:Number):void;

        function moveCallback(xOffset:Number, yOffset:Number, widthRatio:Number, heightRatio:Number):void;

        function whatIsTheSlideInfoCallback(userID:String, xOffset:Number, yOffset:Number, widthRatio:Number, heightRatio:Number):void;

        function maximizeCallback():void;

        function restoreCallback():void;

        function clearCallback():void;

        function gotoSlideCallback(page:Number):void;

        function sharePresentationCallback(name:String, share:Boolean):void;

        function removePresentationCallback(name:String):void;

        function pageCountExceededUpdateMessageCallback(conference:String, room:String, code:String, presentationName:String, messageKey:String, numberOfPage:Number, maxNumberOfPages:Number):void;

        function generatedSlideUpdateMessageCallback(conference:String, room:String, code:String, presentationName:String, messageKey:String, numberOfPages:Number, pagesCompleted:Number):void

        function conversionCompletedUpdateMessageCallback(conference:String, room:String, code:String, presentationName:String, messageKey:String, slidesInfo:String):void

        function conversionUpdateMessageCallback(conference:String, room:String, code:String, presentationName:String, messageKey:String):void;
    }
}