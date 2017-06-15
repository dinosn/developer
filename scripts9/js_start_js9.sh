#!/bin/bash
set -e

if [ -z ${JSENV+x} ]; then
    echo "[-] JSENV is not set, your environment is not loaded correctly."
    exit 1
fi

logfile="/tmp/install.log"
. $CODEDIR/github/jumpscale/developer/jsenv-functions.sh

export bname=js9_base
export iname=js9

usage() {
   cat <<EOF
Usage: js9_start [-n $name] [-p $port]
   -n $name: name of container
   -p $port: port on which to install
   -b: build the docker, don't download from docker
   -r: reset docker, destroy first if already on host
   -h: help

   example to do all: 'js9_start -n mymachine -p 2223' which will start a container with name myachine on port 2223 and download
   also works with specifying nothing

EOF
   exit 0
}


doreset(){
    docker inspect $iname >  /dev/null 2>&1 &&  docker rm  -f "$iname" > /dev/null 2>&1
}

port=2222
pulled=0

while getopts "n:p:rbh" opt; do
   case $opt in
   n )  iname=$OPTARG ;;
   p )  port=$OPTARG ;;
   b )  build=1 ;;
   r )  reset=1 ;;
   h )  usage ; exit 0 ;;
   \?)  usage ; exit 1 ;;
   esac
done
shift $(($OPTIND - 1))

docker inspect $bname >  /dev/null 2>&1 &&  docker rm  -f $bname > /dev/null 2>&1

if [ -n "${reset}" ]; then
    doreset ;
fi


if ! docker images | grep -q "jumpscale/$bname"; then
    if [ -n "${build}" ]; then
        bash js_builder_base9.sh -l
    else
        pulled=1
    fi
fi

echo "[+] starting jumpscale9 development environment"

existing="$(docker ps -aq -f name=^/${iname}$)"

if [[ -z "$existing" ]]; then

    # -v ${GIGDIR}/data/:/optvar/data
    docker run --name $iname \
        --hostname $iname \
        -d \
        -p ${port}:22 -p 10700-10800:10700-10800 \
        --device=/dev/net/tun \
        --cap-add=NET_ADMIN --cap-add=SYS_ADMIN \
        --cap-add=DAC_OVERRIDE --cap-add=DAC_READ_SEARCH \
        -v ${GIGDIR}/:/root/gig/ \
        -v ${GIGDIR}/code/:/opt/code/ \
        jumpscale/$bname > ${logfile} 2>&1 || die "docker could not start, please check ${logfile}"
else
    docker start $iname  > ${logfile} 2>&1 || die "docker could not start, please check ${logfile}"
fi

# this to make sure docker is fully booted before executing in it
sleep 2

if [ $pulled -eq 1 ]; then
    # if we are here, this mean that:
    # - base image was not found on local system
    # - build argument was not specified
    # - when docker runs, it pull'd the image from internet
    # we need to adapt this public image now
    ssh_authorize "${iname}"
fi

# copyfiles
# linkcmds

ssh_authorize "${iname}"

echo "* update jumpscale code (js9_code update -a jumpscale -f )"
ssh -A root@localhost -p ${port} 'export LC_ALL=C.UTF-8;export LANG=C.UTF-8;js9_code update -a jumpscale -f'
echo "* init js9 environment (js9_init)"
ssh -A root@localhost -p ${port} 'js9_init' #> ${logfile} 2>&1 || die "docker could not start, please check ${logfile}"


# configzerotiernetwork
#
# autostart


echo "[+] docker started"
echo "[+] please access over ssh using:"
echo "[+]    ssh -tA root@localhost -p ${port}"
