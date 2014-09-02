#!/bin/bash
set -x

COMMANDS='echo -e "o\nn\np\n1\n\n\nw" | fdisk /hostdev/sdb'

MYSCRIPT="
  docker run -t --rm --privileged -v /dev:/hostdev debian \
  	$COMMANDS
  \
  exit;"
# "  # echo -e "o\nn\np\n1\n\n\nw" | fdisk /hostdev/sdb
#   "

boot2docker ssh "$MYSCRIPT"
