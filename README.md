# Deploying Apostrophe Projects
#### A step-by-step guide to server configuration

At Punkave, our Apostrophe 2 sites use stagecoach as a local deployment tool and nginx as a revers proxy on our servers. We typically go with a VPS from ServerGrove but lately have been experimenting with Digital Ocean. This guide is written with the following assumptions:

1. You are running some kind of VPS with Ubuntu 12.04 x64 to which you have root access
2. You have installed stagecoach in on your development machine (you can learn how do do that here: http://github.com/punkave/stagecoach)

## Local Setup

In your development environment, you'll want to configure your deployment settings in the project's (aptly named) 'deployment' directory. This folder consists of start and stop scripts, a migrate task, an rsync_exclude and some config files. Most of these should already exist if you started your project from the apostrophe-sandbox. If this is not the case, you'll want to set up a deployment directory at the root of your Apostrophe 2 project that mirrors the files in this repo.

From the root directory of your project:
```
$ git clone https://github.com/colpanik/apostrophe-deployment.git
$ mv apostrophe-deployment deployment
```

Remember to rename "settings.example" and "settings.production.example" to "settings" and "settings.production" respectively. Once that's done, the folder should look something like this:

```
deployment
  |- .gitignore 
  |- dependencies
  |- migrate
  |- README
  |- rsync_exclude.tt
  |- settings
  |- settings.production
  |- start
  |- stop
```

In here, the crucial files you will have to worry about are "settings" and "settings.production". You will first want to edit the settings file to set the PROJECT and SSH_PORT variables.

```
#!/bin/bash

PROJECT=your_project_name
DIR=/opt/stagecoach/apps/$PROJECT
ADJUST_PATH=':'
SSH_PORT=22
```


Now, in the settings.production, add your hostname and server ip like so:

```
#!/bin/bash

USER=your_ssh_username
SERVER=your_server_ip_or_domain_name
```

You can also create files with more deployment settings for other servers.

```
#!/bin/bash

USER=your_other_ssh_username
SERVER=your_other_ip_address
```

Now we'll want to move a few configuration scripts up to your server. First move the punkave-ubuntu-tools directory our of our deployment folder. You will be prompted for a password when you run the rsync command.

```
$ mv deployment/punk-ubuntu-tools /opt/punk-ubuntu-tools
$ rsync -a /opt/punk-ubuntu-tools root@YOUR_SERVER_IP:/opt/punk-ubuntu 
```

Okay! Now, we're going to ssh into our server and run the configuration script. This script automatically installs node.js, mongoDB and all the other goodies necessary to run an Apostrophe 2 site on your VPS.

```
$ ssh root@YOUR_SERVER_IP
```
Enter your root password. Once you're logged in:

```
$bash /opt/punk-ubuntu/configure-for-node.sh your_non_root_username
```

Above, where I say "your_non_root_username", I mean  to say "the ssh user you typically use to log in to your server". If you're on a Digital Ocean VPS, you will only have a root user so you'll have to create one before running the above command.
