#!/bin/bash

# ------
# Functions definitions: here are useful functions we use
# ------
getcode() {
    source=$(pwd)

    mkdir -p "${CODEDIR}/github/jumpscale"
    cd "${CODEDIR}/github/jumpscale"

    if [ ! -e $CODEDIR/github/jumpscale/core9 ]; then
        repository="Jumpscale/$1"
        branch=$GIGBRANCH

        # fallback to master if branch doesn't exists
        if ! branchExists ${repository} ${branch}; then
            branch="master"
        fi

        echo "* Cloning github.com/${repository} [${branch}]"
        git clone -b "${branch}" git@github.com:${repository} || git clone -b "${branch}" https://github.com/${repository}

    else
        echo "* Pulling github.com/${repository} [${branch}]"
        cd $CODEDIR/github/jumpscale/core9
        git pull > /tmp/lastcommandoutput.txt 2>&1
    fi

    cd "${source}"
}

die() {
    echo "[-] something went wrong: $1"
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
