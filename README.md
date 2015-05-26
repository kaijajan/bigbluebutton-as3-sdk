[BigBlueButton](http://www.bigbluebutton.org)是一个开源的在线会议工具。

##Playback
官方回放是用html5來實現的，也說明不會支持flash，所以分析了下xml文件，基本都實現回放了，視頻(webm)還未完成解析。

 * ~~文檔~~
 * ~~白板~~
 * ~~音頻，播放ogg文件~~
 * 視頻，播放webm文件
  
```as3
import cc.minos.bigbluebutton.playback.PlayBack;
var playback:PlayBack = new PlayBack(host);
playback.loadMeeting(meetingId);
//playback.play();
//playback.stop();
//playback.pause();
//playback.clear();
```

## API
```as3
import cc.minos.bigbluebutton.apis.API;

//settings
var api:API = new API( config.host, config.securitySalt );
api.onAdministrationCallback = onAdministrationCallback;
api.onMonitoringCallback = onMonitoringCallback;
api.onRecordingCallback = onRecordingCallback;

//check
api.isMeetingRunning(meetingId);
//join
api.join( name, meetingId, role);
//create
api.create( meetingId, meetingName, attendeePw, moderatorPw, welcomeMsg, diaNumber, voiceBridge, webVocie, logoutUrl, record, duration, meta );

//handlers
function onAdministrationCallback( callName:String, response:Response ):void
{
   if ( response.returncode == "SUCCESS" )
   {
   	  trace(callName);
   }
}

```

##License
LGPLv3