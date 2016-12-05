#!/bin/bash

# Three-Fingered Claw technique
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

basedir="/home/rmay/scripts/bootstrap/"
fast="all"

# Handy Functions
fastmode() { sh $basdir"web-setup.sh"; sh $basdir"backend-setup.sh"; sh $basdir"util-setup.sh"; } 
webmode() { sh web-setup.sh; } 
backendmode() { sh backend-setup.sh; } 
utilmode() { sh util-setup.sh; } 

# Do fastmode
if [ "$1" == "$fast" ]; then (
echo "Executing Fast Mode"; 
fastmode;
);

# Do Slow Menu Mode
else (
echo "Options: "
echo "\"default\" kicks off all 3 provisioning scripts" 
echo "\"1\" kicks off web provisioning script" 
echo "\"2\" kicks off backend provisioning script" 
echo "\"3\" kicks off util provisioning script" 

read -p "Enter choice : " n
case $n in
1) echo "Starting Web" && webmode ;;
2) echo "Starting Backend" && backendmode ;;
3) echo "Starting Util" && utilmode ;;
*) echo "Starting All" && fastmode ;;
esac
) fi;
