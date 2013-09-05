#!/bin/sh

MAILTO=clientscron@punkave.com

# Update packages. Email the above user if there is any output, otherwise
# no email is sent. Start this as a cron job and PUT IT IN THE BACKGROUND
# so it doesn't die if cron itself is updated

# Update at 4am every Sunday with this crontab line:
#0 4 * * 0 /bin/sh /opt/punk-ubuntu/updater.sh &

export DEBIAN_FRONTEND=noninteractive
PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/bin:/bin; export PATH

(dpkg --configure -a &&
apt-get -y -qq update &&
apt-get -y --force-yes -qq -o DPkg::options::=--force-confdef upgrade) >> /tmp/$$ 2>&1
if [ -s "/tmp/$$" ]
then
  /usr/bin/mail -s "Ubuntu Update" $MAILTO < /tmp/$$
  rm /tmp/$$
fi
