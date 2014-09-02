#!/bin/bash

: ${AIRSTACK_PROJECT_DIRNAME:=.airstack}

#${AIRSTACK_SHARE_IP:="$(boot2docker ip)"}
nfs_install() {
	echo "In install_nfs"
	# TMPDIR="/tmp/airstack"
	# #download
	# [ ! -e /tmp/airstack ] && mkdir -v $TMPDIR

	# cd /tmp/airstack
	# wget https://downloads.sourceforge.net/project/unfs3/unfs3/0.9.22/unfs3-0.9.22.tar.gz


	# #check sha
	# sha1="a6c83e1210ce75836c672cd76e66577bfef7a17a"
	# ./configure", "--disable-debug", "--disable-dependency-tracking",
	#                           "--prefix=#{prefix}"
	# make
	# make install
}


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

nfs_install

AIRSTACKIP=$(hostip_get)
echo "AIRSTACKIP=$AIRSTACKIP"
echo "\"$(pwd)\" $AIRSTACKIP(rw,no_root_squash,insecure,removable)" > $(pwd)/$AIRSTACK_PROJECT_DIRNAME/exports
