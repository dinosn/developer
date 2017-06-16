#!/bin/bash
set -e

logfile="/tmp/install.log"
rm -f $logfile
# logfile="/dev/stdout"

if [ "$1" != "" ]; then
    logfile="$1"
fi

# There is one indentation level on echo to make
# a difference from host output, this is run on docker

echo "export LC_ALL=C.UTF-8" >> /root/.profile
echo "export LANG=C.UTF-8" >> /root/.profile

echo "[+]   configuring services"
mkdir -p /var/run/sshd
rm -f /etc/service/sshd/down

echo "[+]   regen ssh keys"
/etc/my_init.d/00_regen_ssh_host_keys.sh > ${logfile} 2>&1

echo "[+]   start ssh"
sv start sshd > ${logfile} 2>&1
