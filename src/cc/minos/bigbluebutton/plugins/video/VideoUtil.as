package cc.minos.bigbluebutton.plugins.video {

    /**
     * ...
     * @author Minos
     */
    public class VideoUtil {

        public function VideoUtil()
        {
        }

        public static function getVideoResolution(stream:String):Array
        {
            var pattern:RegExp = new RegExp("(\\d+x\\d+)-([A-Za-z0-9]+)-\\d+", "");
            if(pattern.test(stream))
            {
                trace("The stream name is well formatted [" + stream + "]");
                trace("Stream resolution is [" + pattern.exec(stream)[ 1 ] + "]");
                trace("Userid [" + pattern.exec(stream)[ 2 ] + "]");
                userID = pattern.exec(stream)[ 2 ];
                return pattern.exec(stream)[ 1 ].split("x");
            }
            else
            {
                trace("The stream name doesn't follow the pattern <width>x<height>-<userId>-<timestamp>. However, the video resolution will be set to the lowest defined resolution in the config.xml: " + resolutions[ 0 ]);
                return resolutions[ 0 ].split("x");
            }
        }

    }

}