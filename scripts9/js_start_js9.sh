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
   -b: build the docker, don't download from docker
   -h: help

   example to do all: 'js9_start -n mymachine -p 2223' which will start a container with name myachine on port 2223 and download
   also works with specifying nothing

EOF
   exit 0
}

PORT=2222
while getopts ":npbh" opt; do
   case $opt in
   n )  iname=$OPTARG ;;
   p )  PORT=$OPTARG ;;
   b )  BUILD=1 ;;
   h )  usage ; exit 0 ;;
   \?)  usage exit0 ;;
   esac
done
shift $(($OPTIND - 1))


trap - ERR
set +e
docker inspect $bname >  /dev/null 2>&1 &&  docker rm  -f $bname > /dev/null 2>&1
docker inspect $iname >  /dev/null 2>&1 &&  docker rm  -f "$iname" > /dev/null 2>&1
trap valid ERR
set -e
if ! docker images | grep -q "jumpscale/$bname"; then
    if [ -n "$BUILD" ]; then
        bash js_builder_base9.sh -l
    fi
fi
echo "* start jumpscale 9 development env based on ub 1704 (to see output do 'tail -f /tmp/lastcommandoutput.txt' in other console)"

# -v ${GIGDIR}/data/:/optvar/data
docker run --name $iname -h $iname -d -p $PORT:22 -p 8000-8100:8000-8100 --device=/dev/net/tun --cap-add=NET_ADMIN --cap-add=SYS_ADMIN -v ${GIGDIR}/:/root/gig/ -v ${GIGDIR}/code/:/opt/code/ jumpscale/$bname sleep 365d  > /tmp/lastcommandoutput.txt 2>&1

initssh

copyfiles
linkcmds

echo "* update jumpscale code (js9_code update -a jumpscale -f )"
ssh -A root@localhost -p 2222 'export LC_ALL=C.UTF-8;export LANG=C.UTF-8;js9_code update -a jumpscale -f'
echo "* init js9 environment (js9_init)"
ssh -A root@localhost -p 2222 'js9_init' > /tmp/lastcommandoutput.txt 2>&1


# configzerotiernetwork
#
# autostart


echo "* SUCCESSFUL, please access over ssh (ssh -tA root@localhost -p $PORT) or using js or jshell"
