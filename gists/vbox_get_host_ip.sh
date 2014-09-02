#!/bin/sh -e
set -x

# Get boot2docker host adapter IP from VirtualBox.
# The host adapter IP is the bridge network IP.
host_adapter_ip() {
  VM_UUID=$(VBoxManage list runningvms | grep boot2docker | cut -d ' ' -f 2 | sed 's/[{}]//g')
  VM_HOSTADAPTER=$(VBoxManage showvminfo $VM_UUID --machinereadable | grep hostonlyadapter | cut -d '=' -f 2 | sed 's/\"//g')
  VM_HOSTADAPTER_IP=$(VBoxManage list hostonlyifs | sed -n -e '/vboxnet0/,/VBoxNetworkName:/ p' | grep IPAddress | tr -d ' ' | cut -d ':' -f 2)
  echo $VM_HOSTADAPTER_IP
}

# Get boot2docker IP.
# This is the IP that docker API runs on. Same as `boot2docker ip`.
boot2docker_ip() {
  VM_BOOT2DOCKER_IP=$(boot2docker ssh "ifconfig eth1" | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
  echo $VM_BOOT2DOCKER_IP
}


echo "Host IP: $(host_adapter_ip)"
echo "Boot2Docker IP: $(boot2docker_ip)"
