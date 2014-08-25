FROM debian:jessie
MAINTAINER airstack team <support@airstack.io>

USER root
ENV HOME /root
WORKDIR /root

# install commands
ENV PKG_INSTALL apt-get update; apt-get install -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold --no-install-recommends --no-install-suggests -y

ENV DEBIAN_FRONTEND noninteractive
ENV AIRSTACK_PKGS_COMMON apt-utils net-tools less curl wget unzip sudo ca-certificates procps jq
ENV AIRSTACK_PKGS_DEVELOPMENT vim-tiny htop ethtool bwm-ng
ENV AIRSTACK_SERVICES dropbear serf haproxy

# DEV INSTALL
RUN set -x; eval $PKG_INSTALL $AIRSTACK_PKGS_COMMON $AIRSTACK_PKGS_DEVELOPMENT

# Set tags via cli
ENV AIRSTACK_TAGS_CLUSTERUUID airstack_cluster
ENV AIRSTACK_TAGS_ROLE base
ENV AIRSTACK_CONNECT base
ENV AIRSTACK_SERVICE_VARS { "base": [{ "type": "base", "ports": { "80": "http", "443": "https" }}, { "type": "logger", "ports": { "514": "tcp" }}]}
ENV AIRSTACK_RUNTIME_VARS ""

ENV AIRSTACK_TAGS_NAME component
ENV AIRSTACK_TAGS_ENV development

ENV AIRSTACK_USER_NAME airstack
ENV AIRSTACK_USER_COMMENT airstack user
ENV AIRSTACK_USER_UID 431
ENV AIRSTACK_USER_GID 432
ENV AIRSTACK_USER_SHELL /bin/nologin
ENV AIRSTACK_USER_PASSWORD airstack

#password set in sshd/run script at ssh start. allows for override via env var.

RUN \
  groupadd --system $AIRSTACK_USER_NAME --gid $AIRSTACK_USER_GID && \
  useradd --uid $AIRSTACK_USER_UID --system --base-dir /home --create-home --gid $AIRSTACK_USER_NAME --shell $AIRSTACK_USER_SHELL --comment "$AIRSTACK_USER_COMMENT" $AIRSTACK_USER_NAME && \
  chown -R $AIRSTACK_USER_NAME:$AIRSTACK_USER_NAME /home/$AIRSTACK_USER_NAME

# DEV LOGIN & SHELL
RUN \
  echo "$AIRSTACK_USER_NAME  ALL = NOPASSWD: ALL" > /etc/sudoers.d/$AIRSTACK_USER_NAME && \
  usermod --shell /bin/bash $AIRSTACK_USER_NAME

#runit install
RUN set -x; eval $PKG_INSTALL runit

#socklog install
ADD config/socklog-unix /etc/airstack/socklog-unix
RUN set -x; eval $PKG_INSTALL socklog ipsvd

#container custom init system
#ENV INIT_DIR /usr/local/etc/container_init
ADD config/runit /etc/airstack/runit
RUN /etc/airstack/runit/runit/enable
ADD config/init/airstack-start /usr/local/bin/airstack-start
CMD exec sudo -E sh /usr/local/bin/airstack-start

#----
# END COMMON HEAD v0.0.2
#
# CUSTOMIZATIONS BELOW
#----

##socklog-klog install
# ADD config/socklog-klog /etc/airstack/socklog-klog
# RUN \
#   eval $PKG_INSTALL socklog ipsvd

#socklog-ucspi-tcp install
ADD config/socklog-ucspi-tcp /etc/airstack/socklog-ucspi-tcp
#RUN set -x; eval $PKG_INSTALL socklog ipsvd

#dropbear install
ADD config/dropbear /etc/airstack/dropbear
RUN set -x; eval $PKG_INSTALL dropbear
EXPOSE 22

# #ssh install
# ADD config/sshd /etc/airstack/sshd
# RUN \
#   ln -s /etc/airstack/sshd/runit/sshd /etc/sv/sshd && \
#   set -x; eval $PKG_INSTALL openssh-server
# EXPOSE 22

# #syslogd install
# ADD config/syslogd/runit/syslogd /etc/sv/syslogd
# RUN apt-get update && apt-get $APT_OPTS install syslogd

# #rsyslog install http://www.rsyslog.com/rsyslog-configuration-builder/
# ADD config/rsyslog /etc/airstack/rsyslog
# RUN \
#   ln -s /etc/airstack/rsyslog/runit/rsyslog /etc/sv/rsyslog && \
#   ln -s /etc/airstack/rsyslog/rsyslog.list /etc/apt/sources.list.d/rsyslog.list && \
#   apt-key adv --recv-keys --keyserver keys.gnupg.net AEF0CF8E && \
#   eval $PKG_INSTALL rsyslog;

#haproxy install (requires a system logger running)
ADD config/haproxy /etc/airstack/haproxy
RUN \
  set -x; eval $PKG_INSTALL haproxy && \
  rm -vf /etc/haproxy/haproxy.cfg && \
  rm -vf /etc/rsyslog.d/haproxy.conf;
EXPOSE 443 80

#serf install
ADD config/serf /etc/airstack/serf
RUN \
  wget -vO serf.zip https://dl.bintray.com/mitchellh/serf/0.6.3_linux_amd64.zip && \
  unzip serf.zip && mv serf /usr/local/bin && rm -vf ./serf.zip
EXPOSE 7946

#consul install
# ADD config/consul /etc/airstack/consul
# RUN \
#   wget -vO consul.zip https://dl.bintray.com/mitchellh/consul/0.3.1_linux_amd64.zip && \
#   unzip consul.zip && sudo chmod +x consul && rm -vf ./consul.zip && sudo mv consul /usr/local/bin/ && \
#   ln -s /etc/airstack/consul/runit/consul /etc/sv/consul
# EXPOSE 8301 8302 8500 8600

# bash -c "echo -e '#!/bin/sh\nexec 2>&1\nexec /usr/sbin/sshd -D -e' > /etc/sv/sshd/run" && \
# bash -c "echo -e '#!/bin/sh\nexec chpst -u root /usr/bin/svlogd -tt /opt/log/sshd' > /etc/sv/sshd/log/run"
#</>
# RUN apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common

# cron w/o checks for lost+found and scans for mtab
# RUN \
#   apt-get update && apt-get -y install cron && apt-get clean && \
#   rm -f /etc/cron.daily/standard
#   echo -e '#!/bin/sh\nexec /usr/sbin/cron -f' > /etc/service/cron.ini

# syslog-ng
# RUN \
#   apt-get update && apt-get -y install syslog-ng-core && apt-get clean && \
#   mkdir -p /var/lib/syslog-ng

RUN \
  mkdir -vp /etc/airstack/vars && \
  echo $AIRSTACK_SERVICE_VARS | jq '' | tee /etc/airstack/vars/service.json && \
  echo $AIRSTACK_RUNTIME_VARS | jq '' | tee /etc/airstack/vars/runtime.json && \
  env | grep AIRSTACK_ | awk '{print ""$1"="$2""}' FS='[=]' | tee /etc/environment

USER airstack
# this runs last
ENV HOME /home/airstack
WORKDIR /home/airstack
