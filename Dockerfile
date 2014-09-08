FROM debian:jessie
MAINTAINER airstack team <support@airstack.io>

USER root
ENV HOME /root
WORKDIR /root



################################################################################
# Packages
################################################################################

# install commands
# TODO: move PKG_INSTALL to core/service-install to get rid of evil eval below
ENV PKG_UPDATE set -x; apt-get update && apt-get upgrade -y
ENV PKG_INSTALL set -x; apt-get update; apt-get install -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold --no-install-recommends --no-install-suggests -y
ENV DEBIAN_FRONTEND noninteractive

# TODO: refactor without eval. or remove and handle elsewhere so not distro-specific

# Try and have binaries that are modified less often up at top of this package section.

RUN eval $PKG_UPDATE

# Packages::Common
RUN eval $PKG_INSTALL apt-utils net-tools less curl wget unzip sudo ca-certificates procps jq

# Packages::Development-Utils
RUN eval $PKG_INSTALL vim-tiny ethtool bwm-ng man-db psmisc gcc

# Packages::runit
RUN eval $PKG_INSTALL runit

# Packages::socklog
RUN eval $PKG_INSTALL socklog ipsvd

# Packages::dropbear
RUN eval $PKG_INSTALL dropbear

# Packages::haproxy
RUN eval $PKG_INSTALL haproxy

# Packages::serf
RUN wget -vO serf.zip https://dl.bintray.com/mitchellh/serf/0.6.3_linux_amd64.zip && \
  unzip serf.zip && mv serf /usr/local/bin && rm -vf ./serf.zip

# Packages::Lua
RUN \
  eval $PKG_INSTALL libssl-dev && \
  eval $PKG_INSTALL luajit luarocks && \
  luarocks install --server=http://rocks.moonscript.org luasec OPENSSL_LIBDIR=/usr/lib/x86_64-linux-gnu/ && \
  luarocks install --server=https://rocks.moonscript.org moonrocks

# Packages::test
RUN moonrocks install --server=https://rocks.moonscript.org busted



################################################################################
# Base Environment
################################################################################

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



################################################################################
# Services
################################################################################

# TODO: do we need this?
ENV AIRSTACK_RUNTIME_VARS ""

#service env vars
# TODO: remove AIRSTACK_SERVICES; use runtime.json
ENV AIRSTACK_SERVICES dropbear serf haproxy

#password set in sshd/run script at ssh start. allows for override via env var.
RUN \
  set -e; groupadd --system airstack --gid 432 && \
  useradd --uid 431 --system --base-dir /home --create-home --gid airstack --shell /bin/nologin --comment "airstack user" airstack && \
  chown -R airstack:airstack /home/airstack

# passwordless sudo enabled for airstack user. should only do for development environment.
# RUN [ $AIRSTACK_TAGS_ENV = "development" ] && echo "airstack  ALL = NOPASSWD: ALL" > /etc/sudoers.d/airstack && usermod --shell /bin/bash airstack
RUN \
  echo "airstack  ALL = NOPASSWD: ALL" > /etc/sudoers.d/airstack && \
  usermod --shell /bin/bash airstack

#runit install
RUN set -x; eval $PKG_INSTALL runit

#socklog install
ADD services/socklog-unix /package/airstack/socklog-unix
RUN set -x; eval $PKG_INSTALL socklog ipsvd

# airstack core utilities
ADD core /package/airstack/core

#container init system
ADD services/runit /package/airstack/runit
RUN /package/airstack/runit/enable

CMD exec sudo -E sh /usr/local/bin/container-start



################################################################################
# Runlevel 2
################################################################################

#dropbear install
ADD services/dropbear /package/airstack/dropbear
EXPOSE 22

#haproxy install
ADD services/haproxy /package/airstack/haproxy
EXPOSE 443 80

#serf install
ADD services/serf /package/airstack/serf
EXPOSE 7946

#env vars
RUN \
  mkdir -vp /etc/airstack && \
  echo $AIRSTACK_RUNTIME_VARS | jq '' | tee /etc/airstack/runtime.json



################################################################################
# DEBUG
# TODO: Delete before distributing
################################################################################

RUN ln -vfs /package/airstack/core/runtime_example.json /etc/airstack/runtime.json


################################################################################
# TESTS
################################################################################

ADD test /package/airstack/test


################################################################################
# COMMON FOOTER
################################################################################

# Change {RAONDOM_STRING} to force upgrade on each build
RUN eval $PKG_UPDATE && echo '{RANDOM_STRING}'

USER airstack
ENV HOME /home/airstack
WORKDIR /home/airstack

