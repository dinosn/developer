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
/etc/my_init.d/00_regen_ssh_host_keys.sh > ${logfile} 2>&1

echo "[+]   updating repositories"
apt-get update > ${logfile} 2>&1

echo "[+]   updating system"
apt-get upgrade -y > ${logfile} 2>&1

echo "[+]   installing python"
apt-get install -y python3 > ${logfile} 2>&1

echo "[+]   installing basic dependencies"
apt-get install -y curl mc openssh-server git net-tools iproute2 tmux localehelper psmisc python3-paramiko python3-psutil> ${logfile} 2>&1


echo "[+]   setting up default environment"
echo "" > /etc/motd
touch /root/.iscontainer

#REALLY BAD PRACTICE DO NOT DO THIS
# echo "[+]   authorizing users"
# mkdir -p /root/.ssh
# chmod 700 /root/.ssh
# for user in $(curl -s https://raw.githubusercontent.com/Jumpscale/developer/master/scripts/devs); do
#     echo "[+]      authorizing $user" > ${logfile}
#     curl -s https://github.com/${user}.keys >> /root/.ssh/authorized_keys
# done

echo "[+]   installing pip system"
cd /tmp
curl -sk https://bootstrap.pypa.io/get-pip.py > get-pip.py
python3 get-pip.py > ${logfile} 2>&1

echo "[+]   installing some pip dependencies"
pip3 install --upgrade pip > ${logfile} 2>&1
pip3 install tmuxp > ${logfile} 2>&1
pip3 install gitpython > ${logfile} 2>&1
pip3 install paramiko --upgrade-strategy only-if-needed --upgrade

echo "[+]   syncronizing developer files"
rsync -rv /opt/code/github/jumpscale/developer/files_guest/ / > ${logfile} 2>&1

echo "[+]   installing jumpscale core9"
pip3 install -e /opt/code/github/jumpscale/core9 > ${logfile} 2>&1

echo "[+]   installing jumpscale prefab9"
pip3 install -e /opt/code/github/jumpscale/prefab9 > ${logfile} 2>&1

echo "[+]   installing binaries files"
# source /root/.jsenv.sh

find  /opt/code/github/jumpscale/core9/cmds -exec ln -s {} "/usr/local/bin/" \; 2> ${logfile}
find  /opt/code/github/jumpscale/developer/cmds_guest -exec ln -s {} "/usr/local/bin/" \; 2> ${logfile}

rm -rf /usr/local/bin/cmds
rm -rf /usr/local/bin/cmds_guest

echo "[+]   initializing jumpscale part1 succesfull"
