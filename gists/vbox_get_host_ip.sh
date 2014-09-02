#!/bin/sh -e
set -x

# Get boot2docker host adapter IP from VirtualBox.
# The host adapter IP is the bridge network IP.
hostip_get() {
  VM_UUID=$(VBoxManage list runningvms | grep boot2docker | cut -d ' ' -f 2 | sed 's/[{}]//g')
  # echo "VM_UUID=$VM_UUID"
  VM_HOSTADAPTER=$(VBoxManage showvminfo $VM_UUID --machinereadable | grep hostonlyadapter | cut -d '=' -f 2 | sed 's/\"//g')
  # echo "VM_HOSTADAPTER=$VM_HOSTADAPTER"
  VM_HOSTADAPTER_IP=$(VBoxManage list hostonlyifs | sed -n -e '/vboxnet0/,/VBoxNetworkName:/ p' | grep IPAddress | tr -d ' ' | cut -d ':' -f 2)
  # echo "VM_HOSTADAPTER_IP=$VM_HOSTADAPTER_IP"
  echo $VM_HOSTADAPTER_IP
  #VM_BOOT2DOCKER_IP=$(boot2docker ssh "ifconfig eth1" | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
  #echo $VM_BOOT2DOCKER_IP
}

echo hostip_get()
