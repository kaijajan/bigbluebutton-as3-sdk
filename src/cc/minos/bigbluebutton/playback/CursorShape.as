package cc.minos.bigbluebutton.playback {
    import flash.display.Shape;

    /**
     * ...
     * @author Minos
     */
    public class CursorShape extends Shape {

        public function CursorShape()
        {
            this.graphics.beginFill(0xcc0000, .5);
            this.graphics.drawCircle(0, 0, 7);
            this.graphics.endFill();
        }

    }

}