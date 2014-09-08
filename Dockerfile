FROM debian:jessie
MAINTAINER airstack team <support@airstack.io>

USER root
ENV HOME /root
WORKDIR /root



################################################################################
# Packages
################################################################################

# install commands
# airstack core utilities
ADD core /package/airstack/core
RUN mkdir -v /command && ln -sv /package/airstack/core/command/* /command/

# Try and have binaries that are modified less often up at top of this package section.

# Packages::Common
RUN /command/core-package-install apt-utils net-tools less curl wget unzip sudo ca-certificates procps jq

# Packages::Development-Utils
RUN /command/core-package-install vim-tiny ethtool bwm-ng man-db psmisc gcc

# Packages::runit
RUN /command/core-package-install runit

# Packages::socklog
RUN /command/core-package-install socklog ipsvd

# Packages::dropbear
RUN /command/core-package-install dropbear

# Packages::haproxy
RUN /command/core-package-install haproxy

# Packages::serf
RUN wget -vO serf.zip https://dl.bintray.com/mitchellh/serf/0.6.3_linux_amd64.zip && \
  unzip serf.zip && mv serf /usr/local/bin && rm -vf ./serf.zip

# Packages::Lua
RUN \
  /command/core-package-install libssl-dev && \
  /command/core-package-install luajit luarocks && \
  luarocks install --server=http://rocks.moonscript.org luasec OPENSSL_LIBDIR=/usr/lib/x86_64-linux-gnu/ && \
  luarocks install --server=https://rocks.moonscript.org moonrocks

# Packages::test
RUN moonrocks install busted



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
RUN /command/core-package-install runit

#socklog install
ADD services/socklog-unix /package/airstack/socklog-unix
RUN /command/core-package-install socklog ipsvd

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

USER airstack
ENV HOME /home/airstack
WORKDIR /home/airstack

