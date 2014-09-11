# Container & Process Stats

#### OSX

we can use `ps` command on OSX to get info about VirtualBox or other daemons running on OSX:

```bash
ps -A -c -o pid,%cpu,%mem,rss,time,etime,command | awk 'NR == 1 || /[V]Box/' | sed -e 's/^ */"/' -e 's/$/\"/g' -e $'s/[[:space:]]\{1,\}/","/g'
```

example output (CSV-formatted!):

```
"PID","%CPU","%MEM","RSS","TIME","ELAPSED","COMMAND"
"358","0.0","0.0","2180","1:07.40","05-04:55:47","VBoxXPCOMIPCD"
"361","0.0","0.0","6928","3:06.20","05-04:55:47","VBoxSVC"
"814","0.0","0.0","856","0:03.36","05-04:38:58","VBoxNetDHCP"
"4844","6.8","12.6","2121580","62:13.60","01-18:52:23","VBoxHeadless"
```

A fuller example that extracts the full command string:

```bash
ps -A -o pid,%cpu,%mem,rss,time,etime,command | awk 'NR == 1 || /[V]Box/' |
awk '{
if (NR == 1) {x=(NF-1);}
out="";
for (i=1;i<=x;i++) {printf "\"%s\",", $i};
gsub(/^[ \t]+/,"",out);
for (i=(x+1);i<=NF;i++) { out=out" "$i }
gsub(/^[ \t]+/,"",out);
printf "\"%s\"", out;
print "";
}'
```

example output:

```
"PID","%CPU","%MEM","RSS","TIME","ELAPSED","COMMAND"
"358","0.0","0.0","2160","1:21.46","06-03:35:46","/Applications/VirtualBox.app/Contents/MacOS/VBoxXPCOMIPCD"
"361","0.0","0.0","6844","3:44.76","06-03:35:46","/Applications/VirtualBox.app/Contents/MacOS/VBoxSVC --auto-shutdown"
"814","0.0","0.0","780","0:03.99","06-03:18:57","/Applications/VirtualBox.app/Contents/MacOS/VBoxNetDHCP --ip-address 192.168.59.99 --lower-ip 192.168.59.103 --mac-address 08:00:27:D7:00:67 --netmask 255.255.255.0 --network HostInterfaceNetworking-vboxnet0 --trunk-name vboxnet0 --trunk-type netadp --upper-ip 192.168.59.254"
"10055","1.1","4.8","800176","4:37.19","15:55:44","/Applications/VirtualBox.app/Contents/MacOS/VBoxHeadless --comment boot2docker-vm --startvm fdd7298b-3793-465b-8f62-0b2902021fff --vrde config"
```

#### Boot2docker and Ubuntu/Linux Hosts

we need to use the /proc file system

full ids of all running docker containers:

```
TMP_CONTAINERIDS=$(docker ps --no-trunc | awk '{if (NR>1) print $1}')
```
OR
```
TMP_CONTAINERIDS=$(docker ps -q --no-trunc)
```

memory usage of all container processes:

```
TMP_CONTAINERIDS=$(docker ps --no-trunc | awk '{if (NR>1) print $1}')
for TMP_CONTAINERID in $TMP_CONTAINERIDS; do
echo Memory Usage of container $TMP_CONTAINERID: $(cat /sys/fs/cgroup/memory/docker/$TMP_CONTAINERID/memory.usage_in_bytes) bytes
done
```

list of pids of processes running in container:

```
TMP_CONTAINERIDS=$(docker ps --no-trunc | awk '{if (NR>1) print $1}')
for TMP_CONTAINERID in $TMP_CONTAINERIDS; do
echo -n PIDS of PROCESSES in container $TMP_CONTAINERID: $(cat /sys/fs/cgroup/cpu/docker/$TMP_CONTAINERID/cgroup.procs)
echo -e "\n"
done
```

get pids / memory usage / cmds of processes running in each container:

```
TMP_CONTAINERIDS=$(docker ps --no-trunc | awk '{if (NR>1) print $1}')
for TMP_CONTAINERID in $TMP_CONTAINERIDS; do
echo "PID   MEM(kB) CMD of processes container $TMP_CONTAINERID":
TMP_PIDS=$(cat /sys/fs/cgroup/cpu/docker/$TMP_CONTAINERID/cgroup.procs)
for TMP_PID in $TMP_PIDS; do
  echo $TMP_PID $(cat /proc/$TMP_PID/status | awk '/VmRSS/ {print $2}') $(cat /proc/$TMP_PID/cmdline | tr "\0" " ")
done
echo -e "\n"
done
```

get total memory usage of all processes in a container:

```
TMP_CONTAINERIDS=$(docker ps --no-trunc | awk '{if (NR>1) print $1}')
for TMP_CONTAINERID in $TMP_CONTAINERIDS; do
echo "CONTAINER ID: $TMP_CONTAINERID"
TMP_PIDS=$(cat /sys/fs/cgroup/cpu/docker/$TMP_CONTAINERID/cgroup.procs)
echo Total Memory Usage: $(echo $( for TMP_PID in $TMP_PIDS; do echo $(cat /proc/$TMP_PID/status | awk '/VmRSS/ {print $2}'); done) | awk ' { for (i=0;i<NF;i++) SUM+=$i} END {print SUM} ')
echo ""
done
```

All together... pids / memory usage / cmds of processes running in each container. And total memory usage of a container:

```
TMP_CONTAINERIDS=$(docker ps --no-trunc | awk '{if (NR>1) print $1}')
for TMP_CONTAINERID in $TMP_CONTAINERIDS; do
echo "CONTAINER ID: $TMP_CONTAINERID"
echo "PID   MEM(kB) CMD":
TMP_PIDS=$(cat /sys/fs/cgroup/cpu/docker/$TMP_CONTAINERID/cgroup.procs)
for TMP_PID in $TMP_PIDS; do
  echo $TMP_PID $(cat /proc/$TMP_PID/status | awk '/VmRSS/ {print $2}') $(cat /proc/$TMP_PID/cmdline | tr "\0" " ")
done
echo ""
echo Total Memory Usage: $(echo $( for TMP_PID in $TMP_PIDS; do echo $(cat /proc/$TMP_PID/status | awk '/VmRSS/ {print $2}'); done) | awk ' { for (i=0;i<NF;i++) SUM+=$i} END {print SUM} ')
echo "==================="
echo ""
done
```

example output:

```
CONTAINER ID: acf26941311cc2f3e4de03713182406b56b6ca86669acb8e76fb5960ec011fb5
PID   MEM(kB) CMD:
2014 8940 /usr/sbin/haproxy -db -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid -sf
23797 2768 /bin/bash
23841 2660 sudo su
23844 2320 su
23853 3180 bash
24043 32 runsvdir -P /etc/service log: ...........................................................................................................................................................................................................................................................................................................................................................................................................
24045 4 runsv socklog-unix
24047 4 runsv haproxy
24048 0 runsv serf
24049 4 runsv sshd
24050 0 svlogd main/main main/auth main/cron main/daemon main/debug main/ftp main/kern main/local main/mail main/news main/syslog main/user
24051 0 /usr/bin/svlogd -tt /opt/log/sshd
24052 552 socklog unix /dev/log
24053 5024 /usr/sbin/sshd -D -e
24054 0 /usr/bin/svlogd -tt /opt/log/haproxy
24056 4 /usr/bin/svlogd -tt /opt/log/serf
24157 11468 serf agent -tag env=development -tag role=base -tag start_time=1407579135 -config-dir=/etc/serf/config/ -iface eth0 -discover=airstack

Total Memory Usage: 34432
===================
```

#### Resources

+ Good post on getting cgroup stats out of linux http://blog.docker.com/2013/10/gathering-lxc-docker-containers-metrics/
+ To access the total memory information about a process on Linux, we use the /proc virtual file system. Within it there is a directory full of information for each active process id (pid). By reading /proc/(pid)/status we can obtain information about memory. http://locklessinc.com/articles/memory_usage/
+ Proc file system general info http://www.thegeekstuff.com/2010/11/linux-proc-file-system/
```
Amongst other things, in Linux version 2.6.39, this file includes:

VmPeak: Peak virtual memory usage
VmSize: Current virtual memory usage
VmLck:  Current mlocked memory
VmHWM:  Peak resident set size
VmRSS:  Resident set size <-- we want this!
VmData: Size of "data" segment
VmStk:  Size of stack
VmExe:  Size of "text" segment
VmLib:  Shared library usage
VmPTE:  Pagetable entries size
VmSwap: Swap space used
```
