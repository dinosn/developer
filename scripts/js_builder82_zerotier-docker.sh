#!/bin/bash
set -e

logfile="/tmp/install.log"

if [ "$1" != "" ]; then
    logfile="$1"
fi

# There is one indentation level on echo to make
# a difference from host output, this is run on docker

echo "[+]   correcting locales env"
echo "export LC_ALL=C.UTF-8" >> /root/.bashrc
echo "export LANG=C.UTF-8" >> /root/.bashrc

echo "export LC_ALL=C.UTF-8" >> /root/.bash_profile
echo "export LANG=C.UTF-8" >> /root/.bash_profile

echo "export LC_ALL=C.UTF-8" >> /root/.profile
echo "export LANG=C.UTF-8" >> /root/.profile

echo "[+]   configuring services"
mkdir -p /var/run/sshd
rm -f /etc/service/sshd/down
/etc/my_init.d/00_regen_ssh_host_keys.sh > ${logfile} 2>&1

echo "[+]   installing dependencies"
apt-get update > ${logfile}
apt-get install -y curl openssh-server git make g++ vim mc localehelper > ${logfile} 2>&1

echo "[+]   downloading zerotier"
git clone --depth=1 https://github.com/zerotier/ZeroTierOne.git > ${logfile} 2>&1
cd ZeroTierOne

echo "[+]   compiling zerotier"
make -j 4 > ${logfile}
make install > ${logfile}

echo "[+]   authorizing users"
mkdir -p /root/.ssh
chmod 700 /root/.ssh
for user in $(curl -s https://raw.githubusercontent.com/Jumpscale/developer/master/scripts/devs); do
    echo "[+]      authorizing $user" > ${logfile}
    curl -s https://github.com/${user}.keys >> /root/.ssh/authorized_keys
done

echo "[+]   configuring zerotier"
ztinit="/etc/my_init.d/10_zerotier.sh"

echo '#!/bin/bash -x' > ${ztinit}
# echo '[ $ZEROTIER_RESET == 1 ] && rm -f /var/lib/zerotier-one/identity.public' >> ${ztinit}
# echo '[ $ZEROTIER_RESET == 1 ] && rm -f /var/lib/zerotier-one/identity.secret' >> ${ztinit}
echo 'zerotier-one -d' >> ${ztinit}
echo 'while ! zerotier-cli info > /dev/null 2>&1; do sleep 0.1; done' >> ${ztinit}
echo '[ "$ZEROTIER_NETWORK" != "" ] && zerotier-cli join $ZEROTIER_NETWORK' >> ${ztinit}

chmod +x ${ztinit}

echo "[+]   installing motd"
curl -s https://raw.githubusercontent.com/Jumpscale/developer/master/mascot > /etc/motd
