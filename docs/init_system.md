################################################################################

### Doc Status: WIP


# Philosophy

Init systems in *nux distros are currently a
[hot topic](http://www.itworld.com/open-source/434796/systemd-rampages-through-linux-community-godzilla-through-tokyo).
Many Linux distros are switching over to
[systemd](http://en.wikipedia.org/wiki/Systemd) due to its ability to start
daemons in parallel and without a shell.

For Airstack, we evaluated all of the leading init systems, implemented a few
(circus, supervisord, systemd, runit) and then settled on runit. Why? Because
runit is lightweight and adheres to
[Unix philosophies](http://en.wikipedia.org/wiki/Unix_philosophy). Basically, we
chose the init system that worked the best for our requirements and was least
contentious in the devops community.

In principal, Airstack is independent of specific init systems since a developer
can easily create a container that uses whatever tools she wants. In practice,
Airstack/core (the default Airstack base container) relies on runit.

We don't think that other init systems are bad, but given the larger vision of
where we want to take Airstack, it's important to keep all of our core services
as lightweight and future proof as possible.


# Runit

In the container, all services are started in parallel in runit stage 2.
If a service has a dependency, it should handle it in the enable script.
See dependency resolution below.


## See [container_config.md](container_config.md)


# TODO

- add support for AIRSTACK_RUNTIME_VARS.services[SERVICE].run
- add docs and implement health checks as a standard for every service
- add support for finish script

# Runit vs Systemd

- https://news.ycombinator.com/item?id=8295468
- https://wiki.debian.org/Debate/initsystem/systemd


# Runit For LFS:

Using canonical runit runlevels:

initialize:
- `/etc/runit/1`

run:
- `/etc/runit/2`

shutdown:
- `/etc/runit/3`

* Arbitrary commands after system projects start up.
Add to:
`/etc/rc.local`

## Commands:
- `container-start` to start the init system.
- `container-stop` to stop the init system.
- `container-status` to stop the init system.

- http://smarden.org/runit/sv.8.html
- https://supermarket.getchef.com/cookbooks/runit

sysv service command is the way most people know to control and show status of services:
- `service < option > | --status-all | [ service_name [ command | --full-restart ] ]`

Using symlinks to integrate with sysv `service` command. So now these are equivalent:
- `service serf status` == `sv status serf`

This also works, but since there are additional files in rc files other than just the current running services, it shows the status of additional programs also:
- `service --status-all` is nearly equivalent to `sv status /etc/service/*`


## Dependency resolution

With the exception of commands found in rc.local, all Services in Runlevel 2 execute in parallel by default. If your service requires another service to run before it, your startup script needs to ensure that any required services are started and running:

Example service script:
```
#!/bin/sh

# ensure that `npm start` doesn't execute unless mongo is running.
service mongo status || exit 1

npm start
```

Another example service script:
```
#!/bin/sh

# Ensure that `npm start` doesn't execute unless mongo is running.
# If mongo is not running, this script will START mongo into its desired state (usually the UP state).
service mongo start || exit 1

npm start
```

Inspiration:
- service {servicename} COMMAND
- start/stop/restart/status {servicename}


Examples:

Aligned with Runit ppl for LFS project:
- http://www.linuxquestions.org/questions/linux-from-scratch-13/runit-for-lfs-without-sysvinit-official-release-4175506569/
- https://code.google.com/p/runit-for-lfs/

Runit vs Systemd etc:
- http://www.linuxquestions.org/questions/slackware-14/s6-or-runit-not-systemd-4175465428/

Ppl's Runit examples:
- https://github.com/chneukirchen/ignite/
- http://powerman.name/download/Gentoo/
- https://github.com/voidlinux/runit-void

Unix Program Philosophy:
- http://thedjbway.b0llix.net/djbwhy.html

Djb-ish utils:
- http://untroubled.org/daemontools-encore/
- http://cr.yp.to/daemontools.html

Runit docs:
- http://chneukirchen.org/talks/ignite/chneukirchen2013slcon.pdf

Articles about current issues about systemd etc:
- http://www.infoworld.com/d/data-center/you-have-your-windows-in-my-linux-249483
- http://www.infoworld.com/d/data-center/its-time-split-linux-in-two-249704

Runit & docker for Sysadmins:
- http://www.debian-administration.org/article/697/Using_runit_for_maintaining_services
- http://www.debian-administration.org/article/698/Automating_the_creation_of_docker_images


# References and Related

- [Daemon Showdown](http://www.tuicool.com/articles/qy2EJz3) – upstart vs runit vs systemd vs ...
- [HackerNews discussion on systemd](https://news.ycombinator.com/item?id=8295468)

