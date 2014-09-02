#!/bin/sh -e
set -x

# Partition unmounted disk in boot2docker.
# Useful when mounting volumes into VBox for database volumes, etc.
partition_volume() {
  COMMANDS='echo -e "o\nn\np\n1\n\n\nw" | fdisk /hostdev/sdb'
  MYSCRIPT="
    docker run -t --rm --privileged -v /dev:/hostdev debian \
      $COMMANDS
    \
    exit;"
  boot2docker ssh "$MYSCRIPT"
}

format_volume() {
  # TODO: mkfs -ext3 ...
}

partition_volume()
format_volume()
