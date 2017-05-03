#!/bin/bash
source ~/.jsenv.sh
source $CODEDIR/github/jumpscale/core9/cmds/js9_base

export bname=js9_base
export iname=js9

function usage () {
   cat <<EOF
Usage: js9_start [-n $name] [-p $port]
   -n $name: name of container
   -p $port: port on which to install
   -h: help

   example to do all: 'js9_start -n mymachine -p 2223' which will start a container with name myachine on port 2223
   also works with specifying nothing

EOF
   exit 0
}

PORT=2222

while getopts ":nph" opt; do
   case $opt in
   n )  iname=$OPTARG ;;
   p )  PORT=$OPTARG ;;
   h )  usage ; exit 0 ;;
   \?)  usage exit0 ;;
   esac
done

shift $(($OPTIND - 1))


trap nothing ERR
docker rm --force $iname >/dev/null 2>&1
docker rm --force $bname >/dev/null 2>&1
trap valid ERR

if ! docker images | grep -q "jumpscale/$bname"; then
    sh js_builder_base9.sh -lp
fi

echo "* start jumpscale 9 development env based on ub 1704 (to see output do 'tail -f /tmp/lastcommandoutput.txt' in other console)"

# -v ${GIGDIR}/data/:/optvar/data
docker run --name $iname -h $iname -d -p $PORT:22 --device=/dev/net/tun --cap-add=NET_ADMIN --cap-add=SYS_ADMIN -v ${GIGDIR}/:/root/gig/ -v ${GIGDIR}/code/:/opt/code/ jumpscale/$bname sleep 365d  > /tmp/lastcommandoutput.txt 2>&1

initssh

copyfiles
linkcmds

initjs

# configzerotiernetwork
#
# autostart


echo "* SUCCESSFUL, please access over ssh (ssh -tA root@localhost -p $PORT) or using js or jshell"
