package cc.minos.bigbluebutton.plugins.users {

    import cc.minos.bigbluebutton.events.BigBlueButtonEvent;
    import cc.minos.bigbluebutton.events.MadePresenterEvent;
    import cc.minos.bigbluebutton.events.UsersEvent;
    import cc.minos.bigbluebutton.models.BBBUser;
    import cc.minos.bigbluebutton.models.IUsersList;
    import cc.minos.bigbluebutton.models.UsersList;
    import cc.minos.bigbluebutton.plugins.Plugin;

    import flash.net.Responder;

    /**
     * UsersPlugin
     * manager participants, listeners & meeting status
     * @author Minos
     */
    public class UsersPlugin extends Plugin implements IParticipantsSOServiceClient, IListenersSOServiceClient, IUsersPlugin {
        /* remote application name */

        //get recording status
        protected const GET_RECORDING_STATUS:String = "participants.getRecordingStatus";
        //set recording status, it can change recording status
        protected const SET_RECORDING_STATUS:String = "participants.setRecordingStatus";
        //get all of users in the meeting
        protected const GET_PARTICIPANTS:String = "participants.getParticipants";
        //change user's status
        protected const SET_PARTICIPANT_STATUS:String = "participants.setParticipantStatus";
        //assign someone to presenter
        protected const SET_PRESENTER:String = "participants.assignPresenter";
        //get voice users
        protected const GET_MEETMEUSERS:String = "voice.getMeetMeUsers";
        //meeting status
        protected const GET_ROOM_MUTE_STATE:String = "voice.isRoomMuted";
        //
        protected const GET_LOCK_SETTINGS:String = "lock.getLockSettings";
        protected const GET_ROOM_LOCK_STATE:String = "lock.isRoomLocked";
        //lock status
        protected const SET_LOCK_USER:String = "voice.lockMuteUser";
        //mute status
        protected const SET_MUTE_USER:String = "voice.muteUnmuteUser";
        //mute all users
        protected const SET_MUTE_ALL_USER:String = "voice.muteAllUsers";
        //kick out someone from the meeting
        protected const SET_KILL_USER:String = "voice.kickUSer";

        //users manager
        protected var _usersList:IUsersList;
        //settings
        protected var options:UsersOptions;

        //participants sharedobject service
        protected var participantsSO:ParticipantsSOService;
        //listeners sharedobject service
        protected var listenersSO:ListenersSOService;

        private var responder:Responder = new Responder(
                // On successful result
                function (result:Boolean):void
                {
                },
                // On error occurred
                function (status:Object):void
                {
                    trace("Error occurred:");
                    for(var x:Object in status)
                    {
                        trace(x + " : " + status[ x ]);
                    }
                });

        public function UsersPlugin(options:UsersOptions = null)
        {
            super();
            if(options == null)
                options = new UsersOptions();
            this.options = options;
            this._name = "[UsersPlugin]";
            this._shortcut = "users";
        }

        /**
         *
         */
        override public function start():void
        {
            participantsSO.connect(connection, uri);
            listenersSO.connect(connection, uri);

            bbb.send(GET_PARTICIPANTS, new Responder(onGetParticipantsResult, onGetStatus));

            //bbb.send( GET_LOCK_SETTINGS, new Responder( onGetLockSettingsResult , onGetStatus) );
            //bbb.send( GET_RECORDING_STATUS, new Responder( onGetRecordingResult ) );
            bbb.send(GET_MEETMEUSERS, new Responder(onGetMeetMeUsersResult, onGetStatus));
            bbb.send(GET_ROOM_MUTE_STATE, new Responder(muteStateCallback, onGetStatus));
            //bbb.send( GET_ROOM_LOCK_STATE, new Responder( onGetRoomLockStateResult, onGetStatus ) );
        }

        /**
         *
         */
        override public function stop():void
        {
            participantsSO.disconnect();
            listenersSO.disconnect();
        }

        /**
         *
         */
        override public function get uri():String
        {
            return super.uri + "/" + bbb.conferenceParameters.room;
        }

        override public function init():void
        {
            _usersList = new UsersList();

            participantsSO = new ParticipantsSOService(this);
            listenersSO = new ListenersSOService(this);

        }

        protected function onGetStatus(status:Object):void
        {
            for(var x:Object in status)
            {
                trace(x + " : " + status[ x ]);
            }
        }

        protected function onGetRecordingResult(result:Object):void
        {
            trace(name + " recording status: " + result);
            var changeEvent:BigBlueButtonEvent = new BigBlueButtonEvent(BigBlueButtonEvent.CHANGE_RECORDING_STATUS)
            changeEvent.data.remote = true;
            changeEvent.data.recording = result;
            dispatchRawEvent(changeEvent);
        }

        protected function onGetParticipantsResult(result:Object):void
        {
            if(result.count > 0)
            {
                trace("online: " + result.count, name);
                for(var p:Object in result.participants)
                {
                    participantJoined(result.participants[ p ]);
                }
            }
            if(options.autoPresenter && usersList.hasOnlyOneModerator())
            {
                var user:BBBUser = usersList.getTheOnlyModerator();
                if(user)
                {
                    trace("assign presenter >" + user.name + "[" + user.userID + "]", name);
                    assignPresenter(user.userID, user.name, 1);
                }
            }
        }

        protected function onGetMeetMeUsersResult(result:Object):void
        {
            if(result.count > 0)
            {
                trace(name + " voice: " + result.count);
                for(var p:Object in result.participants)
                {
                    var u:Object = result.participants[ p ];
                    userJoin(u.participant, u.name, u.name, u.muted, u.talking, u.locked);
                }
            }
        }

        public function participantJoined(joinedUser:Object):void
        {
            var user:BBBUser = new BBBUser();
            user.userID = joinedUser.userid;
            user.name = joinedUser.name;
            user.role = joinedUser.role;
            user.externUserID = joinedUser.externUserID;
            user.isLeavingFlag = false;

            if(user.userID == userID)
            {
                user.me = true;
                usersList.me = user;
            }
            usersList.addUser(user);

            sendUsersEvent(UsersEvent.JOINED, user.userID);

            participantStatusChange(user.userID, "hasStream", joinedUser.status.hasStream);
            participantStatusChange(user.userID, "presenter", joinedUser.status.presenter);
            participantStatusChange(user.userID, "raiseHand", joinedUser.status.raiseHand);
        }

        public function participantLeft(userID:String):void
        {
            var user:BBBUser = usersList.getUser(userID);
            if(user != null)
            {
                user.isLeavingFlag = true;
                sendUsersEvent(UsersEvent.LEFT, user.userID);
                usersList.removeUser(userID);
            }
        }

        public function assignPresenter(userID:String, name:String, assignedBy:Number):void
        {
            bbb.send(SET_PRESENTER, responder, userID, name, assignedBy);
        }

        public function assignPresenterCallback(userID:String, name:String, assignedBy:String):void
        {
            var pEvent:MadePresenterEvent;

            if(this.userID == userID)
            {
                trace(this.name + " Received " + name + " switch to presenter");
                pEvent = new MadePresenterEvent(MadePresenterEvent.SWITCH_TO_PRESENTER_MODE);
            }
            else
            {
                trace(this.name + " Received " + name + " switch to viewer");
                pEvent = new MadePresenterEvent(MadePresenterEvent.SWITCH_TO_VIEWER_MODE);
            }
            pEvent.userID = userID;
            pEvent.assignerBy = assignedBy;
            pEvent.presenterName = name;
            dispatchRawEvent(pEvent);
        }

        public function kickUser(userID:String):void
        {
            if(options.allowKickUser)
            {
                participantsSO.kickUser(userID);
            }
        }

        public function kickUserCallback(userID:String):void
        {
            trace("kickUserCallback: " + userID, name);
            sendUsersEvent(UsersEvent.KICKED, userID);

            if(this.userID == userID)
            {
                bbb.disconnect(false);
            }
        }

        public function logout():void
        {
            var endEvent:BigBlueButtonEvent = new BigBlueButtonEvent(BigBlueButtonEvent.END_MEETING);
            dispatchRawEvent(endEvent);
        }

        public function participantStatusChange(userID:String, status:String, value:Object):void
        {
            var user:BBBUser = usersList.getUser(userID);
            if(user != null)
            {
                trace("status change: " + userID + "." + status + "=" + value, name);
                switch(status)
                {
                    case "presenter":
                        user.presenter = value as Boolean;
                        var mEvent:MadePresenterEvent = new MadePresenterEvent(MadePresenterEvent.PRESENTER_NAME_CHANGE);
                        mEvent.userID = user.userID;
                        dispatchRawEvent(mEvent);
                        break;
                    case "hasStream":
                        var streamInfo:Array = String(value).split(/,/);
                        user.hasStream = ( String(streamInfo[ 0 ]).toUpperCase() == "TRUE" );
                        var streamNameInfo:Array = String(streamInfo[ 1 ]).split(/=/);
                        user.streamName = streamNameInfo[ 1 ];
                        if(user.hasStream)
                        {
                            sendUsersEvent(UsersEvent.USER_VIDEO_STREAM_STARTED, user.userID);
                        }
                        else
                        {
                            if(user.streamName != null)
                            {
                                user.streamName = null;
                                sendUsersEvent(UsersEvent.USER_VIDEO_STREAM_STOPED, user.userID);
                            }
                        }
                        break;
                    case "raiseHand":
                        user.raiseHand = value as Boolean;
                        sendUsersEvent(UsersEvent.RAISE_HAND, user.userID);
                        break;
                }
            }

        }

        /* */
        public function onGetLockSettingsResult(result:Object):void
        {
            trace(name + " onGetLockSettingsResult ");
        }

        public function onGetRoomLockStateResult(lock:Boolean):void
        {
            trace(name + " Received lock status [ " + lock + " ]");
        }

        public function muteStateCallback(mute:Boolean):void
        {
            trace(name + " Received mute status [ " + mute + " ]");
        }

        public function userLeft(voiceID:Number):void
        {
            var user:BBBUser = usersList.getUserByVoiceID(voiceID);
            if(user)
            {
                user.voiceJoined = false;
                user.voiceUserID = 0;
                user.talking = false
                user.voiceMuted = false;
                user.voiceLocked = false;
                sendUsersEvent(UsersEvent.USER_VOICE_LEFT, user.userID);
            }
        }

        public function userTalk(voiceID:Number, talk:Boolean):void
        {
            var user:BBBUser = usersList.getUserByVoiceID(voiceID);
            if(user)
            {
                user.talking = talk;
                sendUsersEvent(UsersEvent.USER_VOICE_TALKING, user.userID);
            }
        }

        public function userLockedMute(voiceID:Number, locked:Boolean):void
        {
            var user:BBBUser = usersList.getUserByVoiceID(voiceID);
            if(user)
            {
                user.voiceLocked = locked;
                sendUsersEvent(UsersEvent.USER_VOICE_LOCKED, user.userID);
            }
        }

        public function userMute(voiceID:Number, mute:Boolean):void
        {
            var user:BBBUser = usersList.getUserByVoiceID(voiceID);
            if(user)
            {
                user.voiceMuted = mute;
                sendUsersEvent(UsersEvent.USER_VOICE_MUTED, user.userID);
                if(user.voiceMuted)
                {
                    userTalk(voiceID, false);
                }
            }
        }

        public function userJoin(voiceID:Number, cidName:String, cidNum:String, muted:Boolean, talking:Boolean, locked:Boolean):void
        {
            if(cidName)
            {
                var pattern:RegExp = /(.*)-bbbID-(.*)$/;
                var result:Object = pattern.exec(cidName);

                if(result != null)
                {
                    if(usersList.hasUser(result[ 1 ]))
                    {
                        trace(name + " voice join: " + cidName);
                        var user:BBBUser = usersList.getUser(result[ 1 ]);
                        user.voiceUserID = voiceID;
                        user.voiceMuted = muted;
                        user.voiceJoined = true;
                        user.talking = talking;
                        user.voiceLocked = locked;
                        sendUsersEvent(UsersEvent.USER_VOICE_JOINED, user.userID);
                    }
                }
            }
        }

        private var pingCount:int = 0;

        public function ping(message:String):void
        {
            if(pingCount < 100)
            {
                pingCount++;
            }
            else
            {
                var date:Date = new Date();
                var t:String = date.toLocaleTimeString();
                trace("[" + t + '] - Received ping from server: ' + message);
                pingCount = 0;
            }
        }

        protected function sendUsersEvent(type:String, userID:String):void
        {
            var usersEvent:UsersEvent = new UsersEvent(type);
            usersEvent.userID = userID;
            dispatchRawEvent(usersEvent);
        }

        public function recordingStatusChange(userID:String, recording:Boolean):void
        {
            trace(name + " Received recording status change [ " + userID + "," + recording + " ]");
            onGetRecordingResult(recording);
        }

        /* INTERFACE cc.minos.bigbluebutton.plugins.users.IUsersPlugin */

        public function changeRecordingStatus(recording:Boolean):void
        {
            bbb.send(SET_RECORDING_STATUS, responder, userID, recording);
        }

        public function raiseHand(userID:String, raise:Boolean):void
        {
            bbb.send(SET_PARTICIPANT_STATUS, responder, userID, "raiseHand", raise);
        }

        public function ejectVoiceUser(voiceID:Number):void
        {
            bbb.send(SET_KILL_USER, responder, voiceID);
        }

        public function muteAllUsers(mute:Boolean, dontMuteThese:Array = null):void
        {
            if(dontMuteThese == null) dontMuteThese = [];
            bbb.send(SET_MUTE_ALL_USER, responder, mute);
        }

        public function muteUser(voiceID:Number, mute:Boolean):void
        {
            bbb.send(SET_MUTE_USER, responder, voiceID, mute);
        }

        public function lockUser(voiceID:Number, lock:Boolean):void
        {
            bbb.send(SET_LOCK_USER, responder, voiceID, lock);
        }

        public function addStream(userID:String, streamName:String):void
        {
            bbb.send(SET_PARTICIPANT_STATUS, responder, userID, "hasStream", "true,stream=" + streamName);
        }

        public function removeStream(userID:String, streamName:String):void
        {
            bbb.send(SET_PARTICIPANT_STATUS, responder, userID, "hasStream", "false,stream=" + streamName);
        }

        public function get usersList():IUsersList
        {
            return _usersList;
        }
    }
}