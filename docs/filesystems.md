################################################################################

### Doc Status: WIP


# Container Filesystem

todo
- input/output dirs
- bind mounting
- samba -> vbox -> container
- ...

See [djb filesystem](standards.md) in standards.md.




# Samba

TODO: remove this below samba info after fully implementing in CLI. This doc
  should only contain an overview of Samba.

### Install

```bash
# osx
brew install samba
```

Installs smbd at ` /usr/local/Cellar/samba/3.6.23/sbin/smbd`


### Config

```bash
# /usr/local/Cellar/samba/3.6.23/etc/smb.conf
# add the following...

[global]
  security = user
  map to guest = Bad User
  load printers = no
  printing = bsd
  printcap name = /dev/null
  show add printer wizard = no
  disable spoolss = yes

[base0]
  hosts allow = 192.168.59.*
  guest ok = yes
  writeable = yes
  path = /Users/j/airstack/airstack/airsdk/base
```

Notes:
- for `hosts allow`, use the ip of the docker host-only network ip.
- for `path`, use the project directory
- for `base0`, use the project name with a number or some unique thing. this will be the share name.

run this on your mac to get samba server running on port 9000 (can also put this in a process supervisor...):

```bash
smbd -F --log-stdout --no-process-group -d 1 -p 9000
```

run this from within your boot2docker process to enable the share:

```bash
sudo mkdir -vp /home/docker/base0
sudo mount -t cifs //192.168.59.3/base0 -o username="",guest,port=9000,uid=`id -u docker`,gid=`id -g docker` /home/docker/base0
```

If mount outputs a message about 'operation in progress' it's likely because the OSX firewall is blocking connections.
Disable the 'block all incoming connections' setting in OSX firewall. Stealth mode can still be enabled.

and now this docker command will work from your host...

```bash
docker run -i -t -v /home/docker/base0:/home/airstack/base0 ubuntu /bin/bash
```

to live-restart samba services if the config file changes:

```bash
ps -a | grep "[s]mbd -F" | awk '{print $1}' | xargs kill -HUP
```
