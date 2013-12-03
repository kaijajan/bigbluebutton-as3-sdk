Using the BigBlueButton 0.81-RC4 API.

API Resources
=============

Administration
	* create						Creates a new meeting.
	* getDefaultConfigXML		Gets the default config.xml (these settings configure the BigBlueButton client for each user).
	* setConfigXML				Add a custom config.xml to an existing meeting.
	* join						Join a new user to an existing meeting.
	* end						Ends meeting.
	
Monitoring
	* isMeetingRunning			Checks whether if an specified meeting is running.
	* getMeetings				Get a list of the Meetings.
	* getMeetingInfo				Get the details of a Meeting.
	
Recording
	* getRecordings				Get a list of recordings.
	* publishRecordings			Enables to publish or unpublish a recording.
	* deleteRecordings			Deletes a existing Recording
	
[API](https://code.google.com/p/bigbluebutton/wiki/API)