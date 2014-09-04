FROM debian:jessie
MAINTAINER airstack team <support@airstack.io>

USER root
ENV HOME /root
WORKDIR /root

#----
# Base Environment
#----

# install commands
# TODO: move PKG_INSTALL to core/service-install to get rid of evil eval below
ENV PKG_INSTALL apt-get update; apt-get install -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold --no-install-recommends --no-install-suggests -y
ENV DEBIAN_FRONTEND noninteractive

# TODO: load all tags from json then remove these ENVs
ENV AIRSTACK_TAGS_CLUSTERNAME airstack_cluster
ENV AIRSTACK_TAGS_NAME component
ENV AIRSTACK_TAGS_ENV development
ENV AIRSTACK_TAGS_ROLE base

# TODO: see PKG_INSTALL todo above
# base packages install
# RUN service-install apt-utils net-tools less curl wget unzip sudo ca-certificates procps jq
# install development packages if in development environment
# RUN [ $AIRSTACK_TAGS_ENV = "development" ] && service-install $AIRSTACK_PKGS_DEVELOPMENT

# TODO: REMOVE THIS ....
ENV AIRSTACK_PKGS_COMMON apt-utils net-tools less curl wget unzip sudo ca-certificates procps jq
ENV AIRSTACK_PKGS_DEVELOPMENT vim-tiny ethtool bwm-ng man-db psmisc
RUN set -x; eval $PKG_INSTALL $AIRSTACK_PKGS_COMMON $AIRSTACK_PKGS_DEVELOPMENT

#----
# Services
#----

# TODO: do we need this?
ENV AIRSTACK_RUNTIME_VARS ""

#service env vars
# TODO: remove AIRSTACK_SERVICES; use runtime.json
ENV AIRSTACK_SERVICES dropbear serf haproxy

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
ADD services/socklog-unix /package/airstack/conf/socklog-unix
RUN set -x; eval $PKG_INSTALL socklog ipsvd

#container init system
ADD services/runit /package/airstack/conf/runit
RUN /package/airstack/conf/runit/enable

CMD exec sudo -E sh /usr/local/bin/container-start

#----
# Runlevel 2
#----

#socklog-ucspi-tcp install
ADD services/socklog-ucspi-tcp /package/airstack/conf/socklog-ucspi-tcp

#dropbear install
ADD services/dropbear /package/airstack/conf/dropbear
RUN set -x; eval $PKG_INSTALL dropbear
EXPOSE 22

#haproxy install
ADD services/haproxy /package/airstack/conf/haproxy
RUN \
  set -x; eval $PKG_INSTALL haproxy && \
  rm -vf /etc/haproxy/haproxy.cfg && \
  rm -vf /etc/rsyslog.d/haproxy.conf;
EXPOSE 443 80

#serf install
ADD services/serf /package/airstack/conf/serf
RUN \
  wget -vO serf.zip https://dl.bintray.com/mitchellh/serf/0.6.3_linux_amd64.zip && \
  unzip serf.zip && mv serf /usr/local/bin && rm -vf ./serf.zip
EXPOSE 7946

ADD core /package/airstack/conf/core

#env vars
RUN \
  mkdir -vp /etc/airstack && \
  echo $AIRSTACK_RUNTIME_VARS | jq '' | tee /etc/airstack/runtime.json

#----
# COMMON FOOTER
#----

USER airstack
ENV HOME /home/airstack
WORKDIR /home/airstack
