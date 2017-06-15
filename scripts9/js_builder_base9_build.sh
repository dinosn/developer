#!/bin/bash
set -e

if [ -z ${JSENV+x} ]; then
    echo "[-] JSENV is not set, your environment is not loaded correctly."
    exit 1
fi

# source ~/.jsenv.sh
# source $CODEDIR/github/jumpscale/core9/cmds/js9_base
. $CODEDIR/github/jumpscale/developer/jsenv-functions.sh

logfile="/tmp/install.log"
rm -f $logfile

export iname="js9_base0"

docker inspect $iname   > /dev/null 2>&1 && docker rm -f $iname > /dev/null

echo "[+] building docker base image"
echo "[+] follow progression: docker exec -t $iname tail -f /tmp/install.log"

docker run \
    --name "${iname}" \
    --hostname "${iname}" \
    -d --device=/dev/net/tun \
    --cap-add=NET_ADMIN --cap-add=SYS_ADMIN \
    --cap-add=DAC_OVERRIDE --cap-add=DAC_READ_SEARCH \
    -v ${GIGDIR}/:/root/gig/ \
    -v ${GIGDIR}/code/:/opt/code/ \
    phusion/baseimage > ${logfile}

# this to make sure docker is fully booted before executing in it
sleep 2

# /opt/code is hardcoded, it runs inside the docker
dockerscript="/opt/code/github/jumpscale/developer/scripts9/js_builder_base9_build_step1-docker.sh"
docker exec -t $iname bash ${dockerscript} || dockerdie ${iname} ${logfile}


if [ -n "$install_libs" ]; then
    dockerscript="/opt/code/github/jumpscale/developer/scripts9/js_builder_base9_build_step2-docker.sh"
    docker exec -t $iname bash ${dockerscript} || dockerdie ${iname} ${logfile}
else
    echo "[+]   installing jumpscale lib9"
    pip3 install -e /opt/code/github/jumpscale/lib9 --no-deps > ${logfile} 2>&1
fi

dockerscript="/opt/code/github/jumpscale/developer/scripts9/js_builder_base9_build_step3-docker.sh"
docker exec -t $iname bash ${dockerscript} || dockerdie ${iname} ${logfile}

echo "[+] commiting changes"
docker commit $iname jumpscale/$iname > ${logfile} 2>&1
docker rm -f $iname > ${logfile} 2>&1

echo "[+] build successful (use js9_start to start an env)"
