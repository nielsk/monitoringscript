# monitoringscript

A little script that you run with your crontab to get notified if your CPU gets too hot and eventually sends a mail.
You need lm_sensors and something with which the mail-command works like msmtp.

Before you can run the script, you need to run once
    sudo sensors_detect

And after that I recommend that you run once
    sensors

Then you can change the script to your needs.

The mail gets only sent once for each sensor/disc until you either remove the appropriate file(s) in /tmp or reboot
