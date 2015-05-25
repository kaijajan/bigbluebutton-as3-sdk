[BigBlueButton](http://www.bigbluebutton.org)是一個開源的在線會議工具，後台red5，客戶端則使用flex開發。

**因為需要自行開發客戶端，所以在原有的flex客戶端整理了一些代碼。**

##Playback
官方回放是用html5來實現的，也說明不會支持flash，所以分析了下xml文件，基本都實現回放了，視頻(webm)還未完成解析。

  * ~~文檔~~
  * ~~白板~~
  * ~~音頻，播放ogg文件~~
  * ~~視頻，播放webm文件~~

##API
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