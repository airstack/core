FROM debian:jessie
MAINTAINER airstack team <support@airstack.io>

USER root
ENV HOME /root
WORKDIR /root

#----
# Base Environment
#----

# install commands
ENV PKG_INSTALL apt-get update; apt-get install -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold --no-install-recommends --no-install-suggests -y
ENV DEBIAN_FRONTEND noninteractive


#base env vars 
ENV AIRSTACK_TAGS_CLUSTERUUID airstack_cluster
ENV AIRSTACK_RUNTIME_VARS ""

ENV AIRSTACK_TAGS_NAME component
ENV AIRSTACK_TAGS_ENV development

ENV AIRSTACK_USER_NAME airstack
ENV AIRSTACK_USER_COMMENT airstack user
ENV AIRSTACK_USER_UID 431
ENV AIRSTACK_USER_GID 432
ENV AIRSTACK_USER_SHELL /bin/nologin
ENV AIRSTACK_USER_PASSWORD airstack

# base packages install
ENV AIRSTACK_PKGS_COMMON apt-utils net-tools less curl wget unzip sudo ca-certificates procps jq
ENV AIRSTACK_PKGS_DEVELOPMENT vim-tiny ethtool bwm-ng man-db psmisc
RUN set -x; eval $PKG_INSTALL $AIRSTACK_PKGS_COMMON $AIRSTACK_PKGS_DEVELOPMENT

#----
# Services
#----

#service env vars
ENV AIRSTACK_SERVICES dropbear serf haproxy
ENV AIRSTACK_TAGS_ROLE base
ENV AIRSTACK_CONNECT base
ENV AIRSTACK_SERVICE_VARS { "base": [{ "type": "base", "ports": { "80": "http", "443": "https" }}, { "type": "logger", "ports": { "514": "tcp" }}]}

#password set in sshd/run script at ssh start. allows for override via env var.
RUN \
  groupadd --system $AIRSTACK_USER_NAME --gid $AIRSTACK_USER_GID && \
  useradd --uid $AIRSTACK_USER_UID --system --base-dir /home --create-home --gid $AIRSTACK_USER_NAME --shell $AIRSTACK_USER_SHELL --comment "$AIRSTACK_USER_COMMENT" $AIRSTACK_USER_NAME && \
  chown -R $AIRSTACK_USER_NAME:$AIRSTACK_USER_NAME /home/$AIRSTACK_USER_NAME

#dev user:pass
RUN \
  echo "$AIRSTACK_USER_NAME  ALL = NOPASSWD: ALL" > /etc/sudoers.d/$AIRSTACK_USER_NAME && \
  usermod --shell /bin/bash $AIRSTACK_USER_NAME

#runit install
RUN set -x; eval $PKG_INSTALL runit

#socklog install
ADD services/socklog-unix /etc/airstack/socklog-unix
RUN set -x; eval $PKG_INSTALL socklog ipsvd

#container init system
ADD services/runit /etc/airstack/runit
RUN /etc/airstack/runit/enable

CMD exec sudo -E sh /usr/local/bin/container-start

#----
# Runlevel 2
#----

#socklog-ucspi-tcp install
ADD services/socklog-ucspi-tcp /etc/airstack/socklog-ucspi-tcp

#dropbear install
ADD services/dropbear /etc/airstack/dropbear
RUN set -x; eval $PKG_INSTALL dropbear
EXPOSE 22

#haproxy install
ADD services/haproxy /etc/airstack/haproxy
RUN \
  set -x; eval $PKG_INSTALL haproxy && \
  rm -vf /etc/haproxy/haproxy.cfg && \
  rm -vf /etc/rsyslog.d/haproxy.conf;
EXPOSE 443 80

#serf install
ADD services/serf /etc/airstack/serf
RUN \
  wget -vO serf.zip https://dl.bintray.com/mitchellh/serf/0.6.3_linux_amd64.zip && \
  unzip serf.zip && mv serf /usr/local/bin && rm -vf ./serf.zip
EXPOSE 7946

ADD services/core /etc/airstack/core

#env vars
RUN \
  mkdir -vp /etc/airstack/vars && \
  echo $AIRSTACK_SERVICE_VARS | jq '' | tee /etc/airstack/vars/service.json && \
  echo $AIRSTACK_RUNTIME_VARS | jq '' | tee /etc/airstack/vars/runtime.json && \
  env | grep AIRSTACK_ | awk '{print ""$1"="$2""}' FS='[=]' | tee /etc/environment

#----
# COMMON FOOTER
#----

USER airstack
ENV HOME /home/airstack
WORKDIR /home/airstack
