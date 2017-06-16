#!/bin/bash
set -e

logfile="/tmp/install.log"
# logfile="/dev/stdout"

if [ "$1" != "" ]; then
    logfile="$1"
fi

echo "[+]   initializing jumpscale part3"
python3 -c "from JumpScale9 import j; j.do.initEnv()" > ${logfile} 2>&1
python3 -c "from JumpScale9 import j; j.tools.jsloader.generate()" > ${logfile} 2>&1

echo "[+]   cleanup"
rm -rf /tmp/* /var/tmp/*
rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup
rm -f /etc/ssh/ssh_host_*
rm -rf /root/.cache
mkdir /root/.cache
apt-get clean

echo "[+]   container installation successful"
