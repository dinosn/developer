#!/bin/bash

# ------
# Functions definitions: here are useful functions we use
# ------
getcode() {
    echo "[+] downloading code: ${CODEDIR}/github/jumpscale/$1"

    if [ -e "${CODEDIR}/github/jumpscale/$1" ]; then
        cd "${CODEDIR}/github/jumpscale/$1"
        git pull || return 1
        cd -

    else
        mkdir -p "${CODEDIR}/github/jumpscale" || return 1
        cd "${CODEDIR}/github/jumpscale"

        (git clone git@github.com:Jumpscale/$1.git || git clone https://github.com/Jumpscale/$1.git) || return 1
    fi
}

die() {
    echo "[-] something went wrong: $1"
    exit 1
}

# die and get docker log back to host
# $1 = docker container name, $2 = logfile name, $3 = optional message
dockerdie() {
    if [ "$3" != "" ]; then
        echo "[-] something went wrong in docker $1: $3"
        exit 1
    fi

    echo "[-] something went wrong in docker: $1"
    docker exec -t $iname cat "$2"

    exit 1
}

ssh_authorize() {
    if [ "$1" = "" ]; then
        echo "[-] ssh_authorize: missing container target"
        return
    fi

    echo "[+] authorizing local ssh keys on docker: $1"
    SSHKEYS=$(ssh-add -L)
    docker exec -t "$1" /bin/sh -c "echo \"${SSHKEYS}\" >> /root/.ssh/authorized_keys"
}

#
# Warning: this is bash specific
#
catcherror_handler() {
    if [ "${logfile}" != "" ]; then
        echo "[-] line $1: script error, backlog from ${logfile}:"
        cat ${logfile}
        exit 1
    fi

    echo "[-] line $1: script error, no logging file defined"
    exit 1
}

catcherror() {
    trap 'catcherror_handler $LINENO' ERR
}
