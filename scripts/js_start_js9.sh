#!/bin/bash

export iname=js9devel
export bname=js9
# echo "SSHKEY: $SSHKEYNAME"

docker rm --force $iname >/dev/null 2>&1

source .js_scripts_base.sh

if ! docker images | grep -q "jumpscale/$bname"; then
    sh js_builder_js9.sh
fi

if [ -z $1 ]; then
  echo "Warning if you want to use zerotier do: js_start_js9.sh <ZEROTIERNWID>"
  echo
  echo "  ZEROTIERNWID: The zerotier network in which the jumpscale development container should join."
  echo
fi
ZEROTIERNWID=$1


echo "* start jumpscale 9 development env based on ub 1704 (to see output do 'tail -f /tmp/lastcommandoutput.txt' in other console)"

docker run --name $iname -h $iname -d -p 2222:22 --device=/dev/net/tun --cap-add=NET_ADMIN --cap-add=SYS_ADMIN -v ${GIGDIR}/zerotier-one/:/var/lib/zerotier-one/ -v ${GIGDIR}/:/root/gig/ -v ${GIGDIR}/code/:/opt/code/ -v ${GIGDIR}/data/:/optvar/data jumpscale/$bname sleep 365d  > /tmp/lastcommandoutput.txt 2>&1

initssh

copyfiles

initjs

configzerotiernetwork

autostart


echo "* SUCCESSFUL, please access over ssh (ssh -tA root@localhost -p 2222) or using js or jshell"
