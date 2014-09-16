#
# Conventions Used in this Dockerfile
#
# RUN:
# - single command on one line
# - multiple commands with `set -e`
#
# Packages:
# - use core helper functions to install packages
# - /command/core-package-install
#

FROM debian:jessie
MAINTAINER airstack team <support@airstack.io>

USER root
ENV HOME /root
WORKDIR /root

ONBUILD USER airstack
ONBUILD ENV HOME /home/airstack
ONBUILD WORKDIR /home/airstack


################################################################################
# PACKAGES
################################################################################

# Add commands required for building images.
COPY core/build /package/airstack-0.1.0/build
RUN set -e; \
  ln -s /package/airstack-0.1.0 /package/airstack; \
  chmod -R 1755 /package; \
  mkdir /command; \
  ln -s /package/airstack/build/core-* /command/

# To minimize rebuilds, binaries that are modified less often should be in earlier RUN commands.

# Packages::Base
RUN /command/core-package-install apt-utils net-tools less curl wget unzip sudo ca-certificates procps jq

# Packages::Development-Utils
RUN set -e; \
  /command/core-package-install vim-tiny ethtool bwm-ng man-db info psmisc gcc make; \
  ln -s /usr/bin/vim.tiny /usr/bin/vim

# Packages::runit
RUN set -e; \
  touch /etc/inittab; /command/core-package-install runit

# Packages::socklog
RUN /command/core-package-install socklog ipsvd netcat-openbsd

# Packages::dropbear
RUN /command/core-package-install dropbear

# Packages::haproxy
RUN /command/core-package-install haproxy

# Packages::serf
RUN /command/core-slashpackage-install serf-0.6.3

# Packages::Lua
RUN set -e; \
  /command/core-package-install libssl-dev luajit luarocks; \
  luarocks install --server=http://rocks.moonscript.org luasec OPENSSL_LIBDIR=/usr/lib/x86_64-linux-gnu/; \
  luarocks install --server=https://rocks.moonscript.org moonrocks

# Packages::test
RUN moonrocks install --server=https://rocks.moonscript.org busted


################################################################################
# CONFIG
################################################################################

# Password set in sshd/run script at ssh start. allows for override via env var.
RUN set -e; \
  groupadd --system airstack --gid 432; \
  useradd --uid 431 --system --base-dir /home --create-home --gid airstack --shell /bin/nologin --comment "airstack user" airstack; \
  chown -R airstack:airstack /home/airstack

# TODO: passwordless sudo enabled for airstack user. should only do for development environment.
#       RUN [ $AIRSTACK_TAGS_ENV = "development" ] && echo "airstack  ALL = NOPASSWD: ALL" > /etc/sudoers.d/airstack && usermod --shell /bin/bash airstack
RUN set -e; \
  echo "airstack  ALL = NOPASSWD: ALL" > /etc/sudoers.d/airstack; \
  usermod --shell /bin/bash airstack

# Default run command
CMD exec sudo -E sh /usr/local/bin/container-start


################################################################################
# SERVICES
################################################################################

# Add Airstack core commands
# This should appear as late in the Dockerfile as possible to make builds as
# fast as possible.
COPY core /package/airstack/core
RUN ln -s /package/airstack/core/command/core-* /command/

#
# RUNLEVEL 1
# Start socklog and runit
#

# socklog
COPY services/socklog-unix /package/airstack/socklog-unix

# Container init system
COPY services/runit /package/airstack/runit
RUN /package/airstack/runit/enable

#
# RUNLEVEL 2
#

# dropbear
COPY services/dropbear /package/airstack/dropbear
EXPOSE 22

# serf
COPY services/serf /package/airstack/serf
EXPOSE 7946

# haproxy
COPY services/haproxy /package/airstack/haproxy

# socklog-remote
COPY services/socklog-remote /package/airstack/socklog-remote


################################################################################
# DEBUG
################################################################################

# TODO: remove this later. /command symlinks should be setup by each command.
RUN ln -s /command/core-* /usr/local/bin/


################################################################################
# TESTS
################################################################################

COPY test /package/airstack/test
