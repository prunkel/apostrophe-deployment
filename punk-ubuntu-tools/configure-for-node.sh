#!/bin/bash

USER=$1
USAGE="Usage: bash configure-for-node.sh NONROOTUSERNAME"

if [ -z "$1" ] ; then
  echo $USAGE
  exit 1
fi

# Comment out AcceptEnv in sshd_config, it breaks mongodump over ssh
perl -pi -e 's/^AcceptEnv/#AcceptEnv/' /etc/ssh/sshd_config
service ssh restart

# Allow ssh without a password
mkdir -p /root/.ssh
chmod 700 /root/.ssh
cat <<EOG > /root/.ssh/authorized_keys2
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNEcy13yRJQLd0zR0kYkKNOmgWIAdesdebPtsLTiVGNJdK9AnBszLJMj5Po3VLtCmm47EWiq+nikokxQwWxiK3i6m40PH7g3qMHTWgLMmn17F6l2g7yByc/1J4aZvQQjq0bPCr58UGKlvJZoujY6AYZMpNjeRUwMPOiTV36WVFjbKU3gDDduDczB/xLCMROyIr4FsehLlVnO835GjTVrdnNCMIQbrM9RRzIWJHHIdd9aUs/XS8FqviDLkFSP80U2MGLTrBjQvdG3F9GSZG9pb4Ux/u6sfaAZtBPKDKgv0Mn4l8LzBUh8Oltn2j47/mW+j4j2NZVWVH64S2+Q/Glt6x admin@dude
EOG
mkdir -p /home/$USER/.ssh
cat <<EOG > /home/$USER/.ssh/authorized_keys2
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNEcy13yRJQLd0zR0kYkKNOmgWIAdesdebPtsLTiVGNJdK9AnBszLJMj5Po3VLtCmm47EWiq+nikokxQwWxiK3i6m40PH7g3qMHTWgLMmn17F6l2g7yByc/1J4aZvQQjq0bPCr58UGKlvJZoujY6AYZMpNjeRUwMPOiTV36WVFjbKU3gDDduDczB/xLCMROyIr4FsehLlVnO835GjTVrdnNCMIQbrM9RRzIWJHHIdd9aUs/XS8FqviDLkFSP80U2MGLTrBjQvdG3F9GSZG9pb4Ux/u6sfaAZtBPKDKgv0Mn4l8LzBUh8Oltn2j47/mW+j4j2NZVWVH64S2+Q/Glt6x admin@dude
EOG
chown -R $USER.$USER /home/$USER/.ssh

apt-get -y install git-core subversion

# Our node apps depend on imagemagick, but Ubuntu's version is old and has an issue that
# makes images darken when uploaded, so we build that from source

(apt-get install libjpeg-dev libpng-dev && cd /usr/local/src && wget http://www.imagemagick.org/download/ImageMagick.tar.gz && tar -zxf ImageMagick.tar.gz && cd ImageMagick-* && ./configure && make install && ldconfig /usr/local/lib)

ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime

dpkg --configure -a

apt-get -y update

apt-get -y -o DPkg::options::=--force-confdef upgrade

# Disable but do not clobber apache. Easier if we want it later
update-rc.d apache2 disable

bash /opt/punk-ubuntu/install-updater.sh

cd /opt

git clone https://github.com/punkave/stagecoach.git

cd stagecoach

bash sc-proxy/install-node-and-mongo-on-ubuntu.bash

cp settings.example settings

perl -pi -e "s/nodeapps/$USER/" settings

mkdir apps

chown -R $USER apps

cd sc-proxy

cp config-example.js config.js

npm install

cp upstart/stagecoach.conf /etc/init

start stagecoach

