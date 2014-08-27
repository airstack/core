#!/bin/sh -e

: ${DISK_NAME:=airstack0}

set -e
set -x
#VMNAME="airstack.vmdk"
init1() {
	echo $@
}

init() {
	DISK_FULLPATH="$(pwd)/.airstack/$DISK_NAME"
	echo DISK_FULLPATH=$DISK_FULLPATH

	[ ! -e .airstack ] && mkdir -vp .airstack || echo "[OK] .airstack folder"
	[ ! -e .airstack/airstack.vmdk ] && VBoxManage createhd -filename .airstack/$DISK_NAME.vmdk --size 2000 --format vmdk || echo "[OK] airstack disk created"
	DISK_CONTROLLERNAME=$( VBoxManage showvminfo boot2docker-vm --machinereadable | grep storagecontrollername0= | cut -d '=' -f 2 | sed s/\"//g )
	# echo DISK CONTROLLER NAME: $DISK_CONTROLLERNAME
	DISK_SATAPORTNUM="-2-0"
	# DISK_SATAPORTNAME="$DISK_CONTROLLERNAME$DISK_SATAPORTNUM"
	DISK_SATAPORTNAME=2
	# echo $DISK_SATAPORTNAME
	VBoxManage storageattach boot2docker-vm --storagectl $DISK_CONTROLLERNAME --port $DISK_FULLPATH --type hdd --medium $VMFULLPATH && echo "[OK] airstack disk attached to boot2docker" || echo "[FAIL] Could not attach disk"
}

case $1 in
	init1) init1 $@;;
	*) echo "Usage $0 {init}"; exit 1
esac

# NOTES:

# https://www.virtualbox.org/manual/ch08.html#vboxmanage-storageattach
# $(shell echo "test"; \
# 		  echo CONTROLNAME=$$(VBoxManage showvminfo boot2docker-vm --machinereadable | grep storagecontrollername0= | cut -d '=' -f 2); \
# 		  echo VBoxManage storageattach --storagectl $$CONTROLNAME;\
# )
	  
	#	VBoxManage  
	#VBoxManage internalcommands storageattach 

  # createhd                  --filename <filename>
  #                           [--size <megabytes>|--sizebyte <bytes>]
  #                           [--diffparent <uuid>|<filename>
  #                           [--format VDI|VMDK|VHD] (default: VDI)
  #                           [--variant Standard,Fixed,Split2G,Stream,ESX]
