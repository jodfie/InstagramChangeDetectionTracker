# Instagram Change Detection Tracker
Given Usernames or UserID's Script keeps track and notifies changes to Username from UID.

Run the following in your home directory

```
sudo apt-get install -y curl git
bash -c "$(curl -fsSL https://gist.githubusercontent.com/MagicalCodeMonkey/24a1a4579076a12cda207849b84b9601/raw/InstaTrackChangeDetection.sh)"
```

Create your users.txt file in ~/InstaTrack and put either usernames or user IDs in it. One per line.

Update `~/InstaTrack/apprise/notifier.sh` to send notifications to you as you see fit via apprise framework.

Run `ICDTService.sh` once.

Set up a schedule in your cron to run `ICDTService.sh` at a time(s) of your choosing.
