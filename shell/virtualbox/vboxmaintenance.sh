#!/bin/bash
VBoxManage list --long natnets > /mnt/array/Library/Software/config/baremetal-conf/vbox_nat_network_info.txt

# Poweroff and backup
#VBoxManage controlvm web acpipowerbutton
#cd /mnt/array/VM && cp -R web template/

# Make sure machines are running
VBoxManage startvm web --type headless >> run.log
VBoxManage startvm backend --type headless >> run.log
VBoxManage startvm util --type headless >> run.log

