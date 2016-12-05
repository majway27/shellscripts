#!/bin/bash
sudo -v
newvmname="rmubusvr06"

echo "Creating $newvmname"

vmdir="/home/rmay/VM/$newvmname/"
isodir="/home/rmay/VM/Setup/"

mkdir $vmdir

virt-install \
--name=$newvmname --arch=x86_64 --vcpus=1 --ram=512 --os-type='linux' --os-variant=ubuntuprecise \
--hvm --connect=qemu:///system --network bridge:br0 \
--cdrom=$isodir/ubuntu-12.04.2-server-amd64.iso \
--disk path=/$vmdir/$newvmname.img,size=20 \
--accelerate --vnc --noautoconsole --keymap=es

virsh dumpxml $newvmname >> $vmdir/$newvmname.xml

sudo chown -R rmay:rmay $vmdir
