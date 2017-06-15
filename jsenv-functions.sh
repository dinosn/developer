#!/bin/bash

# ------
# Functions definitions: here are useful functions we use
# ------
branchExists() {
    repository="$1"
    branch="$2"

    echo "* Checking if ${repository}/${branch} exists"
    httpcode=$(curl -o /dev/null -I -s --write-out '%{http_code}\n' https://github.com/${repository}/tree/${branch})

    if [ "$httpcode" = "200" ]; then
        return 0
    else
        return 1
    fi
}

getcode() {
    echo "* get code"
    pushd $CODEDIR/github/jumpscale

    if ! grep -q ^github.com ~/.ssh/known_hosts 2> /dev/null; then
        ssh-keyscan github.com >> ~/.ssh/known_hosts 2>&1
    fi

    if [ ! -e $CODEDIR/github/jumpscale/$1 ]; then
        repository="Jumpscale/$1"
        branch=${2:-${GIGBRANCH}}

        # fallback to master if branch doesn't exists
        if ! branchExists ${repository} ${branch}; then
            branch="master"
        fi

        echo "* Cloning github.com/${repository} [${branch}]"
        (git clone git@github.com:${repository}.git || git clone https://github.com/${repository}.git) || return 1

    else
        pushd $CODEDIR/github/jumpscale/$1
        git pull
        popd
    fi
    popd

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
