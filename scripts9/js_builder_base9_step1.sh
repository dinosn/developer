#!/bin/bash

source ~/.jsenv.sh
source $CODEDIR/github/jumpscale/core9/cmds/js9_base


export iname=js9_base0
trap nothing ERR

docker inspect $iname > /dev/null 2>&1 &&  docker rm  -f $iname > /dev/null 2>&1
docker inspect js9devel >  /dev/null 2>&1 &&  docker rm  -f js9devel > /dev/null 2>&1
docker inspect js9  >  /dev/null 2>&1&&  docker rm  -f js9 > /dev/null 2>&1

trap valid ERR
echo "* BUILDING UBUNTU ZEROTIER (to see output do 'tail -f /tmp/lastcommandoutput.txt' in other console)"
echo "* Starting docker container for ubuntu 1704"
#${GIGDIR}/zerotier-one/:/var/lib/zerotier-one/
docker run --name $iname -h $iname -d --device=/dev/net/tun --cap-add=NET_ADMIN --cap-add=SYS_ADMIN  -v ${GIGDIR}/:/root/gig/ -v ${GIGDIR}/code/:/opt/code/ ubuntu:17.04 sleep 365d > /tmp/lastcommandoutput.txt 2>&1

echo "* Correcting the locales env"
# docker exec -t $iname bash -c 'echo -e "export LC_ALL=C.UTF-8\nexport LANG=C.UTF-8" >> /root/.bashrc' > /tmp/lastcommandoutput.txt 2>&1
# docker exec -t $iname bash -c 'echo -e "export LC_ALL=C.UTF-8\nexport LANG=C.UTF-8" >> /root/.bash_profile' > /tmp/lastcommandoutput.txt 2>&1
docker exec -t $iname bash -c 'echo -e "export LC_ALL=C.UTF-8\nexport LANG=C.UTF-8" >> /root/.profile' > /tmp/lastcommandoutput.txt 2>&1

echo "* Update/Upgrade ubuntu (apt)"
docker exec -t $iname bash -c "cd && apt-get update && apt-get upgrade -y " > /tmp/lastcommandoutput.txt 2>&1

echo "* Install base ubuntu development tools (python3, ...)"
docker exec -t $iname bash -c "cd && apt-get install -y python3" > /tmp/lastcommandoutput.txt 2>&1

echo "* Install base ubuntu requirements tools (mc, make, git, ...)"
docker exec -t $iname bash -c "cd && apt-get install -y curl mc openssh-server git make iproute2 g++ vim tmux localehelper psmisc pkg-config && mkdir /var/run/sshd" > /tmp/lastcommandoutput.txt 2>&1

# docker exec -t $iname/bin/sh -c 'cat /root/.mascot.txt > /etc/motd' > /tmp/lastcommandoutput.txt 2>&1
docker exec -t $iname /bin/sh -c 'echo "" > /etc/motd' > /tmp/lastcommandoutput.txt 2>&1

echo "* mark its a container"
docker exec -t $iname /bin/sh -c "touch /root/.iscontainer"

echo "* make compile zerotier (3-5 min)"
trap nothing ERR
docker exec -t $iname /bin/sh -c "cd /tmp && git clone https://github.com/zerotier/ZeroTierOne.git && cd ZeroTierOne/ && make" > /tmp/lastcommandoutput.txt 2>&1
trap valid ERR
docker exec -t $iname /bin/sh -c "cd /tmp/ZeroTierOne/ && make install" > /tmp/lastcommandoutput.txt 2>&1
docker exec -t $iname /bin/sh -c "rm -rf /tmp/ZeroTierOne"


echo "* update/install python pip"
docker exec -t $iname /bin/sh -c 'cd /tmp && rm -rf get-pip.py && curl -k https://bootstrap.pypa.io/get-pip.py > get-pip.py && python3 get-pip.py' > /tmp/lastcommandoutput.txt 2>&1
docker exec -t $iname /bin/sh -c 'pip3 install --upgrade pip' > /tmp/lastcommandoutput.txt 2>&1
docker exec -t $iname /bin/sh -c 'pip3 install tmuxp' > /tmp/lastcommandoutput.txt 2>&1
docker exec -t $iname /bin/sh -c 'rm -f /tmp/get-pip.py' > /tmp/lastcommandoutput.txt 2>&1


copyfiles
linkcmds


echo "* install jumpscale 9 from pip"
trap nothing ERR
docker exec -t $iname /bin/sh -c 'pip3 install -e /opt/code/github/jumpscale/core9 --upgrade' > /tmp/lastcommandoutput.txt 2>&1
trap valid ERR
initjs

cleanup

commitdocker

echo "* BUILD SUCCESSFUL (use js9_start to start an env)"
