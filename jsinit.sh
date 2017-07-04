#!/bin/sh
set -e

rm -f /tmp/install.log

if ! which curl > /dev/null; then
    echo "[-] curl not found, this is required to bootstrap jsinit"
    exit 1
fi

osx_install() {
    if ! which brew > /dev/null; then
        sudo echo "* Install Brew"
        yes '' | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    sudo echo "* Unlink curl/python/git"
    brew unlink curl   > /tmp/lastcommandoutput.txt 2>&1
    brew unlink python3  > /tmp/lastcommandoutput.txt 2>&1
    brew unlink git  > /tmp/lastcommandoutput.txt 2>&1
    sudo echo "* Install Python"
    brew install --overwrite python3  > /tmp/lastcommandoutput.txt 2>&1
    brew link --overwrite python3  > /tmp/lastcommandoutput.txt 2>&1
    sudo echo "* Install Git"
    brew install git  > /tmp/lastcommandoutput.txt 2>&1
    brew link --overwrite git  > /tmp/lastcommandoutput.txt 2>&1
    sudo echo "* Install Curl"
    brew install curl  > /tmp/lastcommandoutput.txt 2>&1
    brew link --overwrite curl  > /tmp/lastcommandoutput.txt 2>&1

    # brew install snappy
    # sudo mkdir -p /optvar
    # sudo chown -R $USER /optvar
    # sudo mkdir -p /opt
    # sudo chown -R $USER /opt
}

alpine_install() {
    apk add git  > /tmp/lastcommandoutput.txt 2>&1
    apk add curl  > /tmp/lastcommandoutput.txt 2>&1
    apk add python3  > /tmp/lastcommandoutput.txt 2>&1
    apk add tmux  > /tmp/lastcommandoutput.txt 2>&1
    # apk add wget
    # apk add python3-dev
    # apk add gcc
    # apk add make
    # apk add alpine-sdk
    # apk add snappy-dev
    # apk add py3-cffi
    # apk add libffi
    # apk add libffi-dev
    # apk add openssl-dev
    # apk add libexecinfo-dev
    # apk add linux-headers
    # apk add redis
}

ubuntu_install() {
    sudo apt-get install curl git ssh python3 locales -y
    sudo locale-gen en_US.UTF-8
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
}

archlinux_install() {
    sudo pacman -S --needed git curl openssh python3 --noconfirm
}

fedora_install() {
   sudo dnf install -y git curl openssh python3
}

cygwin_install() {
    # Do something under Windows NT platform
    export LANG=C; export LC_ALL=C
    lynx -source rawgit.com/transcode-open/apt-cyg/master/apt-cyg > apt-cyg
    install apt-cyg /bin
    apt-cyg install curl
    # apt-cyg install python3-dev
    # apt-cyg install build-essential
    # apt-cyg install openssl-devel
    # apt-cyg install libffi-dev
    apt-cyg install python3
    # apt-cyg install make
    # apt-cyg install unzip
    apt-cyg install git
    ln -sf /usr/bin/python3 /usr/bin/python
}





main() {
    echo "=========================="
    echo "== jsinit bootstrapping =="
    echo "=========================="
    echo ""

    echo "[+] fetching our cutie mascot"
    curl -s https://raw.githubusercontent.com/Jumpscale/developer/master/mascot?$RANDOM > ~/.mascot.txt
    clear
    cat ~/.mascot.txt
    echo

    export GIGBRANCH=${GIGBRANCH:-"master"}
    export GIGDEVELOPERBRANCH=${GIGDEVELOPERBRANCH:-"master"}

    if [ "$(uname)" = "Darwin" ]; then
        echo "[+] apple plateform detected"

        # Do something under Mac OS X platform
        echo "* INSTALL homebrew, curl, python, git"
        export LANG=C; export LC_ALL=C
        osx_install

    elif [ -e /etc/alpine-release ]; then
        echo "[+] alpine plateform detected"
        alpine_install

    elif [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then
        echo "[+] linux plateform detected"

        dist=`grep DISTRIB_ID /etc/*-release | awk -F '=' '{print $2}'`
        if [ "$dist" = "Ubuntu" ]; then
            echo "[+] ubuntu distribution found"
            ubuntu_install

        elif which pacman > /dev/null 2>&1; then
            echo "[+] archlinux distribution found"
            archlinux_install

        elif which dnf > /dev/null 2>&1; then
            echo "[+] fedora based distribution found"
            fedora_install

        else
            echo "[-] sorry, your distribution is not supported"
            exit 1
        fi

    elif [ "$(expr substr $(uname -s) 1 9)" = "CYGWIN_NT" ]; then
        echo "[+] cygwin based system found"
        cygwin_install
    fi

    echo "[+] downloading generic environment file"
    curl -s https://raw.githubusercontent.com/Jumpscale/developer/$GIGDEVELOPERBRANCH/jsenv.sh?$RANDOM > ~/.jsenv.sh
    sed -i "/export JSENV/a export GIGDIR='${GIGDIR}'" ~/.jsenv.sh
    curl -s https://raw.githubusercontent.com/Jumpscale/developer/$GIGDEVELOPERBRANCH/jsenv-functions.sh?$RANDOM > /tmp/.jsenv-functions.sh
    . /tmp/.jsenv-functions.sh

    echo "[+] loading gig environment file"
    . ~/.jsenv.sh

    echo "[+] creating local environment directories"
    mkdir -p ${CODEDIR}/github/jumpscale

    echo "[+] getcode for core9 & developer jumpscale repo's"
    getcode core9 2>&1 > /tmp/install.log
    getcode developer $GIGDEVELOPERBRANCH 2>&1 > /tmp/install.log

    # You can avoid .bash_profile smashing by setting
    # GIGSAFE environment variable
    if [ -z ${GIGSAFE+x} ]; then
        # check profile file exists, if yes modify
        if [ ! -e $HOMEDIR/.bash_profile ] ; then
            touch $HOMEDIR/.bash_profile
        else
            #make a 1-time backup
            if [ ! -e "$HOMEDIR/.bash_profile.bak" ]; then
                cp $HOMEDIR/.bash_profile  $HOMEDIR/.bash_profile.bak
            fi
        fi

        sed -i.bak '/export SSHKEYNAME/d' $HOMEDIR/.bash_profile
        sed -i.bak '/jsenv.sh/d' $HOMEDIR/.bash_profile

        echo "" >> $HOMEDIR/.bash_profile
        echo "# Added by jsinit script" >> $HOMEDIR/.bash_profile
        echo "export SSHKEYNAME=$SSHKEYNAME" >> $HOMEDIR/.bash_profile
        echo "source ~/.jsenv.sh" >> $HOMEDIR/.bash_profile
    else
        echo "Please make sure to source .jsenv.sh before running any js9_* command"
    fi

    echo "[+] ensure local commands are callable"
    chmod +x ${CODEDIR}/github/jumpscale/developer/cmds_host/*

    echo "[+] cleaning garbage"
    rm -f /usr/local/bin/js9* > /dev/null 2>&1 || true
    rm -rf /usr/local/bin/cmds* > /dev/null 2>&1 || true

    # create private dir
    mkdir -p "${GIGDIR}/private"
    if [ ! -e "$GIGDIR/private/me.toml" ]; then
        echo "* copy templates private files."
        cp $CODEDIR/github/jumpscale/developer/templates/private/me.toml $GIGDIR/private/
    fi

    echo "[+] copy chosen sshpub key"
    mkdir -p $GIGDIR/private/pubsshkeys
    SSHKEYS=$(ssh-add -L) > $GIGDIR/private/pubsshkeys/id_rsa.pub

    echo "[+] please edit templates in ${GIGDIR}/private/"
    echo "[+]    if you don't then installer will ask for it."
    echo "[+]"
    echo "[+] please run 'source ~/.jsenv.sh' or reload your shell"
    echo "[+]    incase you set the GIGSAFE flag you always have to source .jsenv.sh first"
    echo "[+]"
    echo "[+] to get started with jumpscale do 'js9_start -b'"
    echo "[+]     docker needs to be installed locally"
}

main "$@"
