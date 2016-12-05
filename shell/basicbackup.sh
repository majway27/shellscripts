#!/bin/bash

# General Backup
rsync -rvhd /mnt/array/ /backup/ >> /mnt/array/Library/Software/scripts/log/run.log
# Conf
rsync -rvhd /mnt/array/Library/Software/config/ /mnt/usb/conf/ >> /mnt/array/Library/Software/scripts/log/run.log
# Scripts (especially bootstraps for recovery)
rsync -rvhd /mnt/array/Library/Software/scripts/ /mnt/usb/scripts/ >> /mnt/array/Library/Software/scripts/log/run.log
