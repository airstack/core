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
RUN \
  set -e; \
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

# password set in sshd/run script at ssh start. allows for override via env var.
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

