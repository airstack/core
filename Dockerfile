################################################################################
# CORE Dockerfile
# MAINTAINER airstack team <support@airstack.io>
#
# RUN:
# - single commands on one line
# - multiple commands with `set -e`. Separate commands with `;`.
#
# Packages:
# - use core helper functions to install packages
# - /command/core-package-install
#
################################################################################

FROM debian:jessie
USER root
ENV HOME /root
WORKDIR /root
RUN set -e; \
  groupadd --system airstack --gid 432; \
  useradd --uid 431 --system --base-dir /home --create-home --gid airstack --shell /bin/nologin --comment "airstack user" airstack; \
  chown -R airstack:airstack /home/airstack


################################################################################
# PACKAGES
#
# Add commands required for building images.
# To minimize rebuilds, binaries that are modified less often
# should be in earlier RUN commands.
################################################################################

COPY core/build /package/airstack-0.1.0/build
RUN set -e; \
  ln -s /package/airstack-0.1.0 /package/airstack; \
  chmod -R 1755 /package; \
  mkdir /command; \
  ln -s /package/airstack/build/core-* /command/

# Packages::Base
RUN /command/core-package-install jq ca-certificates libssl1.0.0 openssl

# Packages::Development - will be removed in production
RUN set -e; \
  /command/core-package-install vim-tiny ethtool bwm-ng man-db info psmisc net-tools less wget sudo procps; \
  ln -s /usr/bin/vim.tiny /usr/bin/vim

# Packages::runit
RUN touch /etc/inittab && /command/core-package-install runit

# Packages::socklog
RUN /command/core-package-install socklog ipsvd netcat-openbsd

# Packages::dropbear
RUN /command/core-package-install dropbear

# Packages::Lua
RUN set -e; \
  /command/core-package-install luajit lua-posix; \
  mkdir -p /usr/local/share/lua/5.1; \
  ln -s /usr/bin/luajit /usr/bin/lua; \
  ln -s /package/airstack/core/lua/airstack.lua /usr/local/share/lua/5.1/airstack.lua


################################################################################
# SERVICES
#
# Add commands for configuring and managing services
#
# This should stay near the end of the Dockerfile to minimize
# unnecessary rebuilds.
################################################################################

COPY core /package/airstack/core
RUN ln -s /package/airstack/core/command/core-* /command/

# socklog
COPY services/socklog-unix /package/airstack/socklog-unix

# runit
COPY services/runit /package/airstack/runit
RUN /package/airstack/runit/enable

# dropbear
COPY services/dropbear /package/airstack/dropbear
EXPOSE 22


################################################################################
# DEBUG
################################################################################

# TODO: have /command symlinks setup during each service installation.
RUN ln -s /command/core-* /usr/local/bin/


################################################################################
# TESTS
################################################################################

COPY test /package/airstack/test


################################################################################
# RUNTIME
#
# Password-less sudo enabled for airstack user.
# Can remove as part of production container hardening.
#
# Default CMD set here.
################################################################################

RUN set -e; \
  echo "airstack  ALL = NOPASSWD: ALL" > /etc/sudoers.d/airstack; \
  usermod --shell /bin/bash airstack
CMD exec sudo chpst -u root /usr/local/bin/container-start
