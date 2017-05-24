#!/bin/bash

ztnetwork=""
gighome="~/gig"
ask=1
verbose=0
dimage="jumpscale/ubuntu-zerotier"
JSBRANCH="8.2.0"
advanced=0
logfile="/dev/null"

error_handler() {
    EXITCODE=$?

    if [ -z $2 ]; then
        echo "[-] line $1: unexpected error"
        exit ${EXITCODE}
    else
        echo $2
    fi

    exit 1
}

die() {
    echo "[-] $1"
    exit 1
}

isWindows() {
    if [ ! -e /proc/version ]; then
        return 0
    fi

    match=$(grep -q Microsoft /proc/version)
    return $?
}

show_usage() {
    echo "Usage: $0 -z zt-net-id [-v] [-y] [-h] [-a]"
    echo ""
    echo "  -z zt-net-id    The zerotier network in which the jumpscale should join"
    echo "  -v              Enable verbose mode (show commands output)"
    echo "  -h              Show this help message"
    echo "  -y              Do not ask for confirmation"
    echo "  -a              Advanded user mode (host sensible files untouched)"
    echo ""
    echo "Environment variable \$GIGPATH is used to define gig root path"
    echo ""

    exit 1
}

info() {
    echo -e "[+] \033[34;1m${1}: \033[36;1m${2}\033[0m"
}

load_settings() {
    if isWindows; then
        # Windows subsystem 4 linux
        WINDOWSUSERNAME=$(ls -ail /mnt/c/Users/ | grep drwxrwxrwx | grep -v Public | grep -v Default | grep -v '\.\.')
        WINDOWSUSERNAME=${WINDOWSUSERNAME##* }
        GIGPATH=${GIGPATH:-/mnt/c/Users/${WINDOWSUSERNAME}/gig}
    else
        GIGPATH=${GIGPATH:-~/gig}
    fi
}

home_ensure() {
    mkdir -p ${GIGPATH}/data
    mkdir -p ${GIGPATH}/code
    mkdir -p ${GIGPATH}/zerotier-one

    [ -w ${GIGPATH}/data/ ] || die "No write access to ${GIGPATH}/data"
    [ -w ${GIGPATH}/code/ ] || die "No write access to ${GIGPATH}/code"
    [ -w ${GIGPATH}/zerotier-one/ ] || die "No write access to ${GIGPATH}/zerotier-one"
}

docker_prepare() {
    if docker ps -a --format "{{ .Names }}"  | grep -q js82; then
        echo "[+] cleaning up existing container instance"
        docker rm --force js82 > ${logfile}
    fi

    if docker ps -a --format "{{ .Names }}"  | grep -q ubuntu-zerotier; then
        echo "[+] cleaning up existing container instance"
        docker rm --force ubuntu-zerotier > ${logfile}
    fi
}

docker_ensure_image() {
    if docker images | grep -q "${dimage}"; then
        echo "[+] image <${dimage}> found, skipping creation"
        return
    fi

    echo "[+] starting docker container"
    docker run \
      --name ubuntu-zerotier \
      --hostname ubuntu-zerotier \
      -d --device=/dev/net/tun \
      --cap-add=NET_ADMIN --cap-add=SYS_ADMIN \
      -v ${GIGPATH}/zerotier-one/:/var/lib/zerotier-one/ \
      -v ${GIGPATH}/code/:/opt/code/ \
      -v ${GIGPATH}/data/:/optvar/data \
      phusion/baseimage > ${logfile}

    echo "[+] downloading script"
    docker exec -t ubuntu-zerotier curl -s "https://raw.githubusercontent.com/Jumpscale/developer/refactor/scripts/js_builder82_zerotier-docker.sh" -o /tmp/init.sh

    echo "[+] configuring docker"
    docker exec -t ubuntu-zerotier bash /tmp/init.sh ${logfile}

    echo "[+] creating docker image jumpscale/ubuntu-zerotier"
    docker commit ubuntu-zerotier ${dimage} > ${logfile}
    docker rm --force ubuntu-zerotier > ${logfile}
}

docker_create_js() {
    echo "[+] spawning js docker container"
    docker run \
      --name js82 \
      --hostname js82 \
      -d --device=/dev/net/tun \
      --cap-add=NET_ADMIN --cap-add=SYS_ADMIN \
      -v ${GIGPATH}/zerotier-one/:/var/lib/zerotier-one/ \
      -v ${GIGPATH}/code/:/opt/code/ \
      -v ${GIGPATH}/data/:/optvar/data \
      -e ZEROTIER_NETWORK=${ztnetwork} \
      jumpscale/ubuntu-zerotier > ${logfile}

    echo "[+] waiting for zerotier network"
    echo "[ ] (do not forget to allow the container in your network)"
    echo "[ ] (make sure auto assign ip is enabled)"

    while ! docker exec -t js82 zerotier-cli listnetworks | grep ${ztnetwork} | grep -q ' OK ' > ${logfile}; do
        sleep 0.2
    done

    ztaddr=$(docker exec -t js82 zerotier-cli listnetworks | grep ${ztnetwork} | awk '{ print $NF }')
    ztip=$(echo ${ztaddr} | cut -d'/' -f1)
    echo -e "[+] container zerotier ip: \033[32;1m${ztaddr}\033[0m"

    if [ $advanced == 0 ]; then
        echo "[+] cleaning host known_hosts for this target"
        ssh-keygen -f ~/.ssh/known_hosts -R ${ztip} 2> ${logfile}
    fi

    echo "[+] downloading and installing jumpscale [$JSBRANCH]"
    docker exec -t js82 bash -c "rm -f /tmp/install.sh"
    docker exec -t js82 bash -c "curl -sk https://raw.githubusercontent.com/Jumpscale/jumpscale_core8/$JSBRANCH/install/install.sh?$RANDOM > /tmp/install.sh"
    docker exec -t js82 bash -c "export JSBRANCH="${JSBRANCH}" && cd /tmp && bash install.sh" > ${logfile} 2>&1

    if [ $advanced == 0 ]; then
        echo "[+] installing aliases"

        if ! grep -q "alias js82='docker exec -it js82 js'" ~/.bashrc; then
            echo "alias js82='docker exec -it js82 js'" >> ~/.bashrc
        fi
        if ! grep -q "alias ays82='docker exec -it js82 ays'" ~/.bashrc; then
            echo "alias ays82='docker exec -it js82 ays'" >> ~/.bashrc
        fi
        if ! grep -q "alias js82bash='docker exec -it js82 bash'" ~/.bashrc; then
            echo "alias js82bash='docker exec -it js82 bash'" >> ~/.bashrc
        fi
    fi

    echo "[+] creating docker image: jumpscale/js82"
    docker commit js82 jumpscale/js82 > ${logfile}
}

success_message() {
    echo "[+] ================================"
    echo -e "[+] \033[32mCongratulations\033[0m, your docker based jumpscale installation is ready !"
    echo "[+] Sandbox is present in the zerotier network ${ztnetwork} with ip: ${ztip}"
    echo "[+] Run js82, ays82, or js82bash in a new shell to work in your sandbox"
    echo "[+] ssh into your sandbox via: ssh root@${ztip}"
    # echo "[+] Recreate a new jumscale docker without rebuilding as follows:"
    # echo "[+]  docker rm --force js82"
    # echo "[+]  docker run --name js82 -h js82 -d --device=/dev/net/tun --cap-add=NET_ADMIN --cap-add=SYS_ADMIN -v ${GIGPATH}/zerotier-one/:/var/lib/zerotier-one/ -v ${GIGPATH}/code/:/opt/code/ -v ${GIGPATH}/data/:/optvar/data jumpscale/js82"
    echo "[+] ================================"
}

main() {

    while getopts ":z:hg:vy" opt; do
        case $opt in
            z) ztnetwork=$OPTARG ;;
            h) show_usage ;;
            y) ask=0 ;;
            v)
                verbose=1
                logfile="/proc/self/fd/1"
                ;;
            a) advanced=1 ;;
            :)
                echo "[-] option -$OPTARG requires an argument" >&2
                exit 1
                ;;
        esac
    done

    if [ "$ztnetwork" == "" ]; then
        echo "[-] Zerotier Network is required (-z option)"
        exit 1
    fi

    echo "============================"
    echo "== Grid Deployment Script =="
    echo "============================"
    echo ""

    info "GIG Home Path" $GIGPATH
    info "ZeroTier Network" $ztnetwork

    if [ $verbose == 1 ]; then
        info "Verbose mode" "enabled"
    fi

    if [ $verbose == 1 ]; then
        info "Advanced mode" "enabled"
    fi

    echo ""
    if [ $ask == 1 ]; then
        echo "Press ENTER to continue, hit CTRL+C to cancel"
        read
    fi

    echo "[+] preliminary checks"
    home_ensure

    echo "[+] preparing environment"
    docker_prepare
    docker_ensure_image
    docker_create_js
    success_message
}

trap 'error_handler $LINENO' ERR

load_settings
main "$@"
