################################################################################

### Doc Status: WIP

# Syslog Logging

By default, Airstack containers redirect stdout and stderr to /dev/log and send /dev/log to port 1514 on the VBox IP address.

The CLI or other syslog consumer can listen to the aggregated log feed.


# VBox IP

See [init_share.sh](https://github.com/airstack/airstack/blob/master/airsdk/base/make/init_share.sh) for the
authoratative way to obtain the VBox IP.



# Remote Logging

Concept:

tl;dr: remotely send log messages via tcp using existing svlogd daemon

for example (assuming socklog already installed and running):

```
mkdir -v /var/log/socklog/main/toremote/192.168.59.3/
```

contents of `/var/log/socklog/main/toremote/192.168.59.3/config`:

```
+*.*
s1000
n24
N6
t5
!tryto -pv -k 10 -n 10 nc -q0 $(basename $(pwd)) 12000
```

this will:
- log all messages
- rotate every 1000 bytes or every 5 seconds, whichever comes first.
- max of 20 rotated logs kept around (120 secs of logs)
- min of 5 rotated logs kept around (30 secs of logs)
- on every rotation, will try and connect via tcp to a server on port 12000 and send the current log. will timeout every 10 seconds and then retry up to 10 times.

if we use the directory naming scheme as above, we can use this template:

```
+*.*
s1000
n20
N5
!tryto -pv -k 10 -n 10 nc -q0 $(basename $(pwd)) 12000
```


And add the directory to the list of managed directories `/etc/service/socklog-unix/log/run`:

```
#!/bin/sh
exec chpst -ulog svlogd \
  main/main main/auth main/cron main/daemon main/debug main/ftp \
  main/kern main/local main/mail main/news main/syslog main/user main/toremote/192.168.59.3
```

to notify the svlogd service when a remote logger is added or removed, HUP the logger service:

```
# sv h socklog-unix/log
```

## log & network testing:

to test, run this on a host machine. this will listen: (requires socat to be installed):

```
socat tcp-l:12000,reuseaddr,fork -
```

netcat will also kinda work, but it will exit as soon as it receives one message:

```
nc -l 12000
# or
nc -l 192.168.59.3 12000
```

then you can send a message manually using this:

```
nc -q0 192.168.59.3 12000
```

type in a message and then press ctrl-c to exit.

## resources:

runit:

- http://rubyists.github.io/2011/05/02/runit-for-ruby-and-everything-else.html
- http://linsec.ca/Annvix:User_Guide/socklog#Customizing_socklog
- http://smarden.org/socklog/examples.html
- http://cmrg.fifthhorseman.net/wiki/runit/replaceinit

socat and netcat:
- https://stuff.mit.edu/afs/sipb/machine/penguin-lust/src/socat-1.7.1.2/EXAMPLES
- https://www.digitalocean.com/community/tutorials/how-to-use-netcat-to-establish-and-test-tcp-and-udp-connections-on-a-vps

