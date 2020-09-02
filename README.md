# Instagram Change Detection Tracker
Given Usernames or UserID's Script keeps track and notifies changes to Username from UID.

Clone this repository in your home directory.

Open your users.txt file in ~/InstaTrack and put either usernames or user IDs in it. One per line.

Update `~/InstaTrack/apprise/notifier.sh` to send notifications to you as you see fit via apprise framework.

Run `ICDTService.sh` once.

Set up a schedule in your cron to run `ICDTService.sh` at a time(s) of your choosing.

There will be an Excel file named `InstaTracker.xls` which will continuously have your updated results. 
