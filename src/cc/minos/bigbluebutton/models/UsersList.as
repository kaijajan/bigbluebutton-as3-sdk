package cc.minos.bigbluebutton.models {
    import cc.minos.bigbluebutton.Role;

    /**
     * ...
     * @author Minos
     */
    public class UsersList implements IUsersList {
        ///////////////////////
        // PROPERTIES
        ///////////////////////

        private var _users:Array;
        private var _me:BBBUser;

        ///////////////////////
        // METHODS
        ///////////////////////

        public function UsersList()
        {
            _users = [];
            _me = new BBBUser();
        }

        /**
         *

         */
        public function addUser(user:BBBUser):void
        {
            if(!hasUser(user.userID))
            {
                users.push(user);
            }
        }

        public function hasUser(userID:String):Boolean
        {
            var p:Object = getUserIndex(userID);
            if(p != null)
            {
                return true;
            }
            return false;
        }

        public function hasOnlyOneModerator():Boolean
        {
            var p:BBBUser;
            var moderatorCount:int = 0;
            for(var i:int = 0; i < _users.length; i++)
            {
                p = _users[ i ];
                if(p.role == Role.MODERATOR)
                {
                    moderatorCount++;
                }
            }
            if(moderatorCount == 1)
                return true;
            return false;
        }

        public function getTheOnlyModerator():BBBUser
        {
            if(!hasOnlyOneModerator())
                return null;
            var p:BBBUser;
            for(var i:int = 0; i < _users.length; i++)
            {
                p = _users[ i ];
                if(p.role == Role.MODERATOR)
                {
                    return p;
                }
            }
            return null;
        }

        public function getTheOnlyPresenter():BBBUser
        {
            var p:BBBUser;
            for(var i:int = 0; i < _users.length; i++)
            {
                p = _users[ i ];
                if(p.presenter == true)
                {
                    return p;
                }
            }
            return null;
        }

        public function getUser(userID:String):BBBUser
        {
            var p:Object = getUserIndex(userID);
            if(p != null)
            {
                return p.participant as BBBUser;
            }
            return null;
        }

        public function removeUser(userID:String):void
        {
            var p:Object = getUserIndex(userID);
            if(p != null)
            {
                _users.splice(p.index, 1);
            }
        }

        public function getUserByVoiceID(voiceID:Number):BBBUser
        {
            var aUser:BBBUser
            for(var i:int = 0; i < _users.length; i++)
            {
                aUser = _users[ i ];
                if(aUser.voiceUserID == voiceID)
                    return aUser;
            }
            return null;
        }

        /**
         * 根据传入的名字返回用户
         * @param    userName        :    用户名字
         * @return    包含传入名字的数组
         */
        public function getUserByName(userName:String):Array
        {
            var ary:Array = [];
            var aUser:BBBUser
            for(var i:int = 0; i < _users.length; i++)
            {
                aUser = _users[ i ]
                if(aUser.name == userName)
                    ary.push(aUser);
            }
            return ary;
        }

        private function getUserIndex(userID:String):Object
        {
            var aUser:BBBUser;
            for(var i:int = 0; i < _users.length; i++)
            {
                aUser = _users[ i ];
                if(aUser.userID == userID)
                {
                    return { index: i, participant: aUser };
                }
            }
            return null;
        }

        ///////////////////////
        // GETTERS/SETTERS
        ///////////////////////

        public function get users():Array
        {
            return _users;
        }

        public function get me():BBBUser
        {
            return _me;
        }

        public function set me(value:BBBUser):void
        {
            _me = value;
        }

    }
}