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
COPY core/build /package/airstack/build
RUN set -e; \
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
RUN /command/core-package-install socklog ipsvd netcat

# Packages::dropbear
RUN /command/core-package-install dropbear

# Packages::haproxy
RUN /command/core-package-install haproxy

# Packages::serf
RUN set -e; \
  VER="0.6.3"; PKG_NAME="serf" PKG_DIR="/package/$PKG_NAME"; mkdir -vp "$PKG_DIR-$VER"/command; \
  cd $PKG_DIR-$VER; \
  wget -v -O "$PKG_NAME-$VER".zip https://dl.bintray.com/mitchellh/serf/"$VER"_linux_amd64.zip; \
  unzip -o "$PKG_NAME-$VER".zip; rm -v "$PKG_NAME-$VER".zip; \
  echo "Creating custom command..."; \
  rm -f "$PKG_DIR-$VER/command/"*; \
  ln -vs "$PKG_DIR-$VER/serf" "$PKG_DIR-$VER/command/"; \
  echo "Creating symlink $PKG_NAME -> $PKG_NAME-$VER..."; \
  rm -f "$PKG_DIR"; \
  ln -s "$PKG_DIR"-"$VER" "$PKG_DIR"; \
  echo 'Making command links in /command...'; \
  i=serf; rm -f /command/$i'{new}'; \
  rm -f /command/"$i"; \
  ln -vs "$PKG_DIR"/command/"$i" /command/"$i"'{new}'; \
  mv -f /command/"$i"'{new}' /command/"$i"; \
  echo 'Making compatibility links in /usr/local/bin...'; \
  rm -f /usr/local/bin/$i'{new}'; \
  ln -s /command/$i /usr/local/bin/$i'{new}'; \
  mv -f /usr/local/bin/$i'{new}' /usr/local/bin/$i

# Packages::Lua
RUN set -e; \
  /command/core-package-install libssl-dev luajit luarocks; \
  luarocks install --server=http://rocks.moonscript.org luasec OPENSSL_LIBDIR=/usr/lib/x86_64-linux-gnu/; \
  luarocks install --server=https://rocks.moonscript.org moonrocks; \
  moonrocks install --server=https://rocks.moonscript.org luaposix; \
  ln -s /package/airstack/core/lua/airstack.lua /usr/local/lib/lua/5.1/airstack.lua

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
