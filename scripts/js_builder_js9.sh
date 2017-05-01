#!/bin/bash

export iname=js9
export bname=ub1704-zt
# echo "SSHKEY: $SSHKEYNAME"

docker rm --force $iname >/dev/null 2>&1

source .js_scripts_base.sh

if ! docker images | grep -q "jumpscale/$bname"; then
    sh js_builder_ubuntuzerotier.sh
fi


echo "* BUILDING JUMPSCALE 9 on Ubuntu 17.04 (to see output do 'tail -f /tmp/lastcommandoutput.txt' in other console)"
echo "* Starting docker container prepared ubuntu 1704"

docker run --name $iname -h $iname -d --device=/dev/net/tun --cap-add=NET_ADMIN --cap-add=SYS_ADMIN  -v ${GIGDIR}/code/:/opt/code/ -v jumpscale/$bname sleep 365d  > /tmp/lastcommandoutput.txt 2>&1

initssh

docker exec -t $iname bash -c 'rsync -rav /opt/code/github/jumpscale/developer/scripts/ub1704-zt/ /'

docker exec -t $iname /bin/sh -c "touch /root/.iscontainer"

echo "* update python pip"
docker exec -t js9 /bin/sh -c 'pip3 install --upgrade pip' > /tmp/lastcommandoutput.txt 2>&1

echo "* install jumpscale 9 from pip"
docker exec -t js9 /bin/sh -c 'pip3 install -e /opt/code/github/jumpscale/core9 --upgrade' > /tmp/lastcommandoutput.txt 2>&1

initjs

cleanup

commitdocker

echo "* BUILD SUCCESSFUL"
