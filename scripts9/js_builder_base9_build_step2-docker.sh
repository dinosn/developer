#!/bin/bash
set -e

logfile="/tmp/install.log"
# logfile="/dev/stdout"

if [ "$1" != "" ]; then
    logfile="$1"
fi


echo "[+]   installing python3-dev"
apt-get install -y python3-dev > ${logfile} 2>&1

echo "[+]   installing dependencies"
apt-get install -y make g++ vim tmux psmisc pkg-config libssl-dev libffi-dev > ${logfile} 2>&1

echo "[+]   downloading zerotier source code"
cd /tmp
git clone --depth=1 https://github.com/zerotier/ZeroTierOne.git > ${logfile} 2>&1
cd ZeroTierOne/

echo "[+]   compiling zerotier"
make -j 4 > ${logfile} 2>&1
make install > ${logfile} 2>&1
