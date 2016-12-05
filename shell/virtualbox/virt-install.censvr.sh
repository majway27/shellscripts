#!/bin/bash
sudo -v
newvmname="rmcensvr02"

vmdir="/home/rmay/VM/$newvmname/"
isodir="/home/rmay/VM/Setup/"

virt-install \
--name=$newvmname --arch=x86_64 \
--vcpus=1 --ram=512 \
--os-type=linux --os-variant=rhel5 \
--hvm --connect=qemu:///system --network bridge:br0 \
--cdrom=$isodir/CentOS-6.4-x86_64-bin-DVD1.iso \
--disk path=/$vmdir/$newvmname.img,size=20 \
--accelerate --vnc --noautoconsole --keymap=es

virsh dumpxml $newvmname >> $vmdir/$newvmname.xml

sudo chown -R rmay:rmay $vmdir

