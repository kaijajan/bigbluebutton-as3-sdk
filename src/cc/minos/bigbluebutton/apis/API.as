package cc.minos.bigbluebutton.apis {
    import cc.minos.bigbluebutton.apis.resources.*;
    import cc.minos.bigbluebutton.apis.responses.*;

    /**
     * ...
     * @author Minos
     */
    public class API {
        public var onRecordingCallback:Function = null;
        public var onMonitoringCallback:Function = null;
        public var onAdministrationCallback:Function = null;

        protected var securitySalt:String = "your-security";
        protected var host:String = "http://your-server/bigbluebutton/api/";

        public function API(host:String, securitySalt:String)
        {
            if(host.indexOf("http://") != 0 && host.indexOf("https://") != 0)
            {
                host = "http://" + host;
            }
            this.host = host + "/bigbluebutton/api/";
            this.securitySalt = securitySalt;
        }

        /**
         * Creates a new meeting.
         * @param    meetingID
         * @param    name
         * @param    attendeePW
         * @param    moderatorPW
         * @param    welcome
         * @param    dialNumber
         * @param    voiceBridge
         * @param    webVoice
         * @param    logoutURL
         * @param    record
         * @param    duration
         * @param    meta
         * @return
         */
        public function create(meetingID:String, name:String = null, attendeePW:String = null, moderatorPW:String = null, welcome:String = null, dialNumber:String = null, voiceBridge:String = null, webVoice:String = null, logoutURL:String = null, record:String = "false", duration:Number = 0, meta:String = null):CreateResource
        {
            var createRes:CreateResource = new CreateResource(onAdministrationCallback);
            createRes.meetingID = meetingID;
            createRes.name = name;
            createRes.attendeePW = attendeePW;
            createRes.moderatorPW = moderatorPW;
            createRes.welcome = welcome;
            createRes.dialNumber = dialNumber;
            createRes.voiceBridge = voiceBridge;
            createRes.webVoice = webVoice;
            createRes.logoutURL = logoutURL;
            createRes.record = record;
            createRes.duration = duration;
            createRes.meta = meta;
            createRes.call(host, securitySalt);
            return createRes;
        }

        /**
         * Join a new user to an existing meeting.
         * @param    fullName
         * @param    meetingID
         * @param    password
         * @param    createTime
         * @param    userID
         * @param    webVoiceConf
         * @param    configToken
         * @return
         */
        public function join(fullName:String, meetingID:String, password:String, createTime:String = null, userID:String = null, webVoiceConf:String = null, configToken:String = null):JoinResource
        {
            var joinRes:JoinResource = new JoinResource(onAdministrationCallback);
            joinRes.fullName = fullName;
            joinRes.meetingID = meetingID;
            joinRes.password = password;
            joinRes.createTime = createTime;
            joinRes.userID = userID;
            joinRes.webVoiceConf = webVoiceConf;
            joinRes.configToken = configToken;
            joinRes.call(host, securitySalt);
            return joinRes;
        }

        /**
         * Ends meeting.
         * @param    meetingID
         * @param    password
         * @return
         */
        public function end(meetingID:String, password:String):EndResource
        {
            var endRes:EndResource = new EndResource(onAdministrationCallback);
            endRes.meetingID = meetingID;
            endRes.password = password;
            endRes.call(host, securitySalt);
            return endRes;
        }

        /**
         *
         * @param    callName
         * @param    data
         */
        /*protected function onAdministrationCallback( callName:String, response:Response ):void
         {
         //trace( callName );
         //trace( response.returncode );
         trace( response.data );

         switch ( callName )
         {
         case CreateResource.CALL_NAME:
         trace( "meetingID: " + CreateResponse( response ).meetingID );
         break;
         case JoinResource.CALL_NAME:
         break;
         case EnterResource.CALL_NAME:
         JoinResponse( response );
         break;
         }
         }*/

        /**
         * Checks whether if an specified meeting is running.
         * @param    meetingID
         * @return
         */
        public function isMeetingRunning(meetingID:String):RunningResoure
        {
            trace("[API] check meeting: " + meetingID);
            var runningRes:RunningResoure = new RunningResoure(onMonitoringCallback);
            runningRes.meetingID = meetingID;
            runningRes.call(host, securitySalt);
            return runningRes;
        }

        /**
         * Get the details of a Meeting.
         * @param    meetingID
         * @param    password
         * @return
         */
        public function getMeetingInfo(meetingID:String, password:String):MeetingInfoResource
        {
            var infoRes:MeetingInfoResource = new MeetingInfoResource(onMonitoringCallback);
            infoRes.meetingID = meetingID;
            infoRes.password = password;
            infoRes.call(host, securitySalt);
            return infoRes;
        }

        /**
         * Get a list of the Meetings.
         * @return
         */
        public function getMeetings():MeetingsResource
        {
            var meetingsRes:MeetingsResource = new MeetingsResource(onMonitoringCallback);
            meetingsRes.call(host, securitySalt);
            return meetingsRes;
        }

        /*protected function onMonitoringCallback( callName:String, response:Response ):void
         {
         }*/

        /**
         * Get a list of recordings.
         * @param    meetingID
         */
        public function getRecordings(meetingID:String = null):RecordingsResource
        {
            var recordingsRes:RecordingsResource = new RecordingsResource(onRecordingCallback);
            recordingsRes.meetingID = meetingID;
            recordingsRes.call(host, securitySalt);
            return recordingsRes;
        }

        /**
         * Enables to publish or unpublish a recording.
         * @param    recordID
         * @param    publish
         */
        public function publishRecordings(recordID:String, publish:String):PublishRecordingsResource
        {
            var publishRes:PublishRecordingsResource = new PublishRecordingsResource(onRecordingCallback);
            publishRes.recordID = recordID;
            publishRes.publish = publish;
            publishRes.call(host, securitySalt);
            return publishRes;
        }

        /**
         * Deletes a existing Recording
         * @param    recordID
         */
        public function deleteRecordings(recordID:String):DeleteRecordingsResource
        {
            var deleteRes:DeleteRecordingsResource = new DeleteRecordingsResource(onRecordingCallback);
            deleteRes.recordID = recordID;
            deleteRes.call(host, securitySalt);
            return deleteRes;
        }

        /*protected function onRecordingCallback( callName:String, response:Response ):void
         {
         }*/

    }

}