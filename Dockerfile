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
RUN mkdir -v /command; ln -sv /package/airstack/core/command/* /command/

# To minimize rebuilds, binaries that are modified less often should be in earlier RUN commands.

# Packages::Common
RUN /command/core-package-install apt-utils net-tools less curl wget unzip sudo ca-certificates procps jq

# Packages::Development-Utils
RUN /command/core-package-install vim-tiny ethtool bwm-ng man-db info psmisc gcc

# Packages::runit
RUN set -e; \
  touch /etc/inittab; /command/core-package-install runit

# Packages::socklog
RUN /command/core-package-install socklog ipsvd

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
  luarocks install --server=https://rocks.moonscript.org moonrocks

# Packages::test
RUN moonrocks install --server=https://rocks.moonscript.org busted

# Putting these installs here until we decide we permanently want them.
# Packages::staging
RUN /command/core-package-install aria2
RUN /command/core-package-install mksh
RUN /command/core-package-install


################################################################################
# Services
################################################################################

# password set in sshd/run script at ssh start. allows for override via env var.
RUN set -e; \
  groupadd --system airstack --gid 432; \
  useradd --uid 431 --system --base-dir /home --create-home --gid airstack --shell /bin/nologin --comment "airstack user" airstack; \
  chown -R airstack:airstack /home/airstack

# TODO: passwordless sudo enabled for airstack user. should only do for development environment.
#       RUN [ $AIRSTACK_TAGS_ENV = "development" ] && echo "airstack  ALL = NOPASSWD: ALL" > /etc/sudoers.d/airstack && usermod --shell /bin/bash airstack
RUN set -e; \
  echo "airstack  ALL = NOPASSWD: ALL" > /etc/sudoers.d/airstack; \
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
# TODO: John, what service runs in core and needs ports 443 and 80?
#   Move these to a webapp container, yes?
EXPOSE 443 80

#serf install
ADD services/serf /package/airstack/serf
EXPOSE 7946


################################################################################
# DEBUG
################################################################################

# TODO: remove this later. /command symlinks should be setup by each command.
RUN ln -vs /command/core-* /usr/local/bin/


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
