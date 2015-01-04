package cc.minos.bigbluebutton.plugins.chat {
    import cc.minos.bigbluebutton.models.ChatMessageVO;
    import cc.minos.bigbluebutton.plugins.IPlugin;

    /**
     * ...
     * @author Minos
     */
    public interface IChatPlugin extends IPlugin {
        function sendPublicMessage(message:ChatMessageVO):void;

        function sendPrivateMessage(message:ChatMessageVO):void;

        function getPublicChatMessages():void;
    }

}