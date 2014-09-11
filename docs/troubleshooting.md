################################################################################

### Doc Status: WIP


### Occasional filesystem errors on start

```bash
jBook:nodejs joe$ make run_osx
docker run --rm -i -t --volume /Users/joe/Documents/_projects/airship/dev/airstack/airsdk/nodejs/output:/home/airstack/output --volume /home/docker/base0:/home/airstack/base0 --volume /Users/joe/Documents/_projects/airship/dev/airstack/airsdk/nodejs/input:/home/airstack/input:ro --publish-all --workdir /home/airstack --user airstack airstack/nodejs:latest
RUNNING: /usr/local/etc/container_init/S10local_start
S10local_start
Configuring socklog-unix
Enabling socklog-unix
Configuring dropbear
Enabling dropbear
Configuring serf
mkdir: created directory '/etc/serf'
Enabling serf
Configuring haproxy
Generating ssl cert for haproxy Generating RSA private key, 2048 bit long modulus
..........................+++
..................................................................+++
e is 65537 (0x10001)
No value provided for Subject Attribute C, skipped
No value provided for Subject Attribute ST, skipped
No value provided for Subject Attribute localityName, skipped
No value provided for Subject Attribute emailAddress, skipped
writing RSA key
Signature ok
subject=/O=org/CN=org/OU=org
Getting Private key
[OK]
Enabling haproxy
Enabling nodejs
Starting runit process manager
.....listening on /dev/log, gid=65534, uid=65534, starting.
local0.notice: Aug 15 06:41:11 dropbear: fail: -w2: unable to change to service directory: file does not exist
local0.notice: Aug 15 06:41:11 dropbear: ok: run: socklog-unix: (pid 80) 0s
local0.notice: Aug 15 06:41:11 dropbear: [82] Aug 15 06:41:11 Failed loading /etc/dropbear/dropbear_ecdsa_host_key
local0.notice: Aug 15 06:41:11 serf: ok: run: socklog-unix: (pid 80) 0s
local0.notice: Aug 15 06:41:11 haproxy: ok: run: socklog-unix: (pid 80) 0s
local0.notice: Aug 15 06:41:11 haproxy: cat: /var/run/haproxy.pid: No such file or directory
local0.notice: Aug 15 06:41:11 haproxy[83]: Proxy stats started.
local1.notice: Aug 15 06:41:11 haproxy[83]: Proxy stats started.
local0.notice: Aug 15 06:41:11 dropbear: [82] Aug 15 06:41:11 Not backgrounding
local0.notice: Aug 15 06:41:11 serf: ==> Using interface 'eth0' address '172.17.0.66'
local0.notice: Aug 15 06:41:11 serf: ==> Starting Serf agent...
local0.notice: Aug 15 06:41:11 serf: ==> Starting Serf agent RPC...
local0.notice: Aug 15 06:41:11 serf: ==> Serf agent running!
local0.notice: Aug 15 06:41:11 serf:          Node name: '8763f77379f6'
local0.notice: Aug 15 06:41:11 serf:          Bind addr: '172.17.0.66:7946'
local0.notice: Aug 15 06:41:11 serf:           RPC addr: '127.0.0.1:7373'
local0.notice: Aug 15 06:41:11 serf:          Encrypted: false
local0.notice: Aug 15 06:41:11 serf:           Snapshot: false
local0.notice: Aug 15 06:41:11 serf:            Profile: lan
local0.notice: Aug 15 06:41:11 serf:       mDNS cluster: airstack
local0.notice: Aug 15 06:41:11 serf:
local0.notice: Aug 15 06:41:11 serf: ==> Log data will now stream in as it occurs:
local0.notice: Aug 15 06:41:11 serf:
local0.notice: Aug 15 06:41:11 serf:     2014/08/15 06:41:11 [INFO] agent: Serf agent starting
local0.notice: Aug 15 06:41:11 serf:     2014/08/15 06:41:11 [INFO] serf: EventMemberJoin: 8763f77379f6 172.17.0.66
local0.notice: Aug 15 06:41:11 nodejs: Hello from node!
local0.notice: Aug 15 06:41:11 serf:     2014/08/15 06:41:11 [INFO] agent: joining: [172.17.0.66:7946] replay: false
local0.notice: Aug 15 06:41:11 serf:     2014/08/15 06:41:11 [INFO] agent: joined: 1 nodes
local0.notice: Aug 15 06:41:11 serf:     2014/08/15 06:41:11 [INFO] agent.mdns: Joined 1 hosts
local0.notice: Aug 15 06:41:12 serf:     2014/08/15 06:41:12 [INFO] agent: Received event: member-join
local0.notice: Aug 15 06:41:12 nodejs: Hello from node!
local0.notice: Aug 15 06:41:13 nodejs: Hello from node!
local0.notice: Aug 15 06:41:14 nodejs: Hello from node!
```

Rerunning often works. Timing issue?

