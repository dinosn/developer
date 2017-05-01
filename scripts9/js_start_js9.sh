#!/bin/bash
source ~/.jsenv.sh
source $CODEDIR/github/jumpscale/core9/cmds/js9_base

export bname=js9_base
export iname=js9

docker rm --force $iname >/dev/null 2>&1

if ! docker images | grep -q "jumpscale/$bname"; then
    sh js_builder_base9.sh
fi


echo "* start jumpscale 9 development env based on ub 1704 (to see output do 'tail -f /tmp/lastcommandoutput.txt' in other console)"

# -v ${GIGDIR}/data/:/optvar/data
docker run --name $iname -h $iname -d -p 2222:22 --device=/dev/net/tun --cap-add=NET_ADMIN --cap-add=SYS_ADMIN -v ${GIGDIR}/:/root/gig/ -v ${GIGDIR}/code/:/opt/code/ jumpscale/$bname sleep 365d  > /tmp/lastcommandoutput.txt 2>&1

initssh

copyfiles

initjs

configzerotiernetwork

autostart


echo "* SUCCESSFUL, please access over ssh (ssh -tA root@localhost -p 2222) or using js or jshell"
