#!/bin/bash
# Before the script will work, you have to run once "sudo sensors_detect; and after that run "sensors" so you can modify the script to fit your temperature-needs
export DISPLAY=:0 #otherwise notify-send won't work from crontab
mon_mail="mail@domain.org" #The mail address where you want to receive the critical-notification mail
mon_temp1_W=85  #Warning-value Temp1 in °C
mon_temp1_C=90  #Critical-value Temp1 in °C
mon_core0_W=90  #Warning-value Core0 in °C
mon_core0_C=100 #Critical-value Core0 in °C
mon_core2_W=90  #Warning-value Core2 in °C
mon_core2_C=100 #Critical-value Core2 in °C
mon_df_W=90     #Warning-value for df in %
mon_df_C=95     #Critical-value for df in %


#Get the temperatures for temp1 and the CPU-cores and then reduce the output to a number for easier comparisons
mon_temp1=$(sensors | grep -E 'temp1' | awk '{ print $2}' | sed 's/+\([0-9]*\).0°C/\1/g' | head -1)
mon_core0=$(sensors | grep -E 'Core\ 0' | awk '{ print $3}' | sed 's/+\([0-9]*\).0°C/\1/g')
mon_core2=$(sensors | grep -E 'Core\ 2' | awk '{ print $3}' | sed 's/+\([0-9]*\).0°C/\1/g')

#Let's see whether important discs are getting too full
mon_root=$(df -h | grep -E '\ \/$' | awk '{print $5}' | sed 's/\%//g')
mon_home=$(df -h | grep -E '/home' | awk '{print $5}' | sed 's/\%//g')
mon_boot=$(df -h | grep -E '/boot' | awk '{print $5}' | sed 's/\%//g')

#Let's write a mail
SendaMail () {
  echo "USER %CPU %MEM COMMAND" | tee /tmp/mail.txt
  #Top 5 processes that are using up the most CPU when the script runs
  ps aux | sort -nk +3 | tail -5| awk '{print $1 " " $3 " " $4 " " $11 " " $12 " " $13}' >> /tmp/mail.txt
  echo -e "\n" >> /tmp/mail.txt
  #List how much free space is available on each disk
  df -h &> /dev/null >> /tmp/mail.txt
  #Send it
  mail -s "Attention: $1 is critical" $mon_mail < /tmp/mail.txt
}

# Check all the stuff and send out notifications and eventually a mail once
# First we check temperatures
# Temp1
if [ $mon_temp1 -ge $mon_temp1_W ] && [ $mon_temp1 -lt $mon_temp1_C ]; then
  notify-send -u normal WARNING: "Temp1 at $mon_temp1" -t 10000
fi

if [ $mon_temp1 -ge $mon_temp1_C ]; then
  notify-send -u critical WARNING: "Temp1 at $mon_temp1" -t 10000
  if [ ! -f /tmp/mon_temp1 ]; then #check if the named file does not exist; if it exists a mail was already sent in the past otherwise create the file and send the mail
    touch /tmp/mon_temp1 #only one mail is sent instead of each time the script runs and it's still critical; remove manually or with a reboot
    SendaMail Temp1
  fi
fi

# Core0
if [ $mon_core0 -ge $mon_core0_W ] && [ $mon_core0 -lt $mon_core0_C ]; then
  notify-send -u normal WARNING: "Core0 at $mon_core0" -t 10000
fi

if [ $mon_core0 -ge $mon_core0_C ]; then
  notify-send -u critical WARNING: "Core0 at $mon_core0" -t 10000
  if [ ! -f /tmp/mon_core0 ]; then
    touch /tmp/mon_core0 
    SendaMail core0
  fi
fi

#Core2
if [ $mon_core2 -ge $mon_core2_W ] && [ $mon_core2 -lt $mon_core2_C ]; then
  notify-send -u normal WARNING: "Core2 at $mon_core2" -t 10000
fi

if [ $mon_core2 -ge $mon_core2_C ]; then
  notify-send -u critical WARNING: "Core2 at $mon_core2" -t 10000
  if [ ! -f /tmp/mon_core2 ]; then
    touch /tmp/mon_core2
    SendaMail core2
  fi
fi

#And now we check disks
#/
if [ $mon_root -ge $mon_df_W ] && [ $mon_root -lt $mon_df_C ]; then
  notify-send -u normal WARNING: "/ is $mon_root% full" -t 10000
fi

if [ $mon_root -ge $mon_df_C ]; then
  notify-send -u critical WARNING: "/ is $mon_root% full" -t 10000
  if [ ! -f /tmp/mon_root ]; then
    touch /tmp/mon_root
    SendaMail root-partition
  fi
fi

#/home
if [ $mon_home -ge $mon_df_W ] && [ $mon_home -lt $mon_df_C ]; then
  notify-send -u normal WARNING: "/home is $mon_home% full" -t 10000
fi

if [ $mon_home -ge $mon_df_C ]; then
  notify-send -u critical WARNING: "/home is $mon_home% full" -t 10000
  if [ ! -f /tmp/mon_home ]; then
    touch /tmp/mon_home
    SendaMail home-partition
  fi
fi

#/boot
if [ $mon_boot -ge $mon_df_W ] && [ $mon_boot -lt $mon_df_C ]; then
  notify-send -u normal WARNING: "/boot is $mon_boot% full" -t 10000
fi

if [ $mon_boot -ge $mon_df_C ]; then
  notify-send -u critical WARNING: "/boot is $mon_boot% full" -t 10000
  if [ ! -f /tmp/mon_boot ]; then
    touch /tmp/mon_boot
    SendaMail boot-partition
  fi
fi
