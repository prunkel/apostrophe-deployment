#!/bin/sh

# Make sure the updater is correctly installed in cron, if and only if
# this is an Ubuntu box

UBUNTU=`grep -i ubuntu /etc/lsb-release | wc -l`

if [ "$UBUNTU" = "0" ] ; then
  # This is not Ubuntu. Some of our servers aren't. Just exit politely.
  echo "Not ubuntu"
  exit 0
fi

echo "Yup, I'm ubuntu"

# (Re)install the updater. Trash any old cron jobs that dink around
# halfassedly with apt-get and any prior cron job for the updater itself,
# so we always have the latest one
crontab -l | grep -v apt-get | grep -v punk-ubuntu/updater.sh > /tmp/$$.crontab
cat >> /tmp/$$.crontab <<EOM
0 4 * * 0 /bin/sh /opt/punk-ubuntu/updater.sh &
EOM

crontab /tmp/$$.crontab
