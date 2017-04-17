set -ex

if ! type "curl" > /dev/null; then
  echo "curl is not installed, please install"
  exit 1
fi


function osx_install {

    if ! type "brew" > /dev/null; then
      echo "brew is not installed, will install"
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    set +ex
    brew unlink curl
    brew unlink python3
    brew unlink git
    set -ex
    brew install python3
    brew link --overwrite python3
    brew install git
    brew link --overwrite git
    brew install curl
    brew link --overwrite curl

    # brew install snappy
    # sudo mkdir -p /optvar
    # sudo chown -R $USER /optvar
    # sudo mkdir -p /opt
    # sudo chown -R $USER /opt
}


function alpine_install {
    apk add git
    apk add curl
    apk add python3
    apk add tmux
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

function ubuntu_unstall {
    locale-gen en_US.UTF-8
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    dist=`grep DISTRIB_ID /etc/*-release | awk -F '=' '{print $2}'`
    if [ "$dist" == "Ubuntu" ]; then
        echo "found ubuntu"
        apt-get install git
        apt-get install curl git ssh python3 -y
        # apt-get install python3-pip -y
        # apt-get install libssl-dev -y
        # apt-get install python3-dev -y
        # apt-get install build-essential -y
        # apt-get install libffi-dev -y
        # apt-get install libsnappy-dev libsnappy1v5 -y
        # rm -f /usr/bin/python
        # rm -f /usr/bin/python3
        # ln -s /usr/bin/python3.5 /usr/bin/python
        # ln -s /usr/bin/python3.5 /usr/bin/python3
    else
        echo "ONLY ALPINE & UBUNTU LINUX SUPPORTED"
        exit 1
    fi
}

function cygwin_install {
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

if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform
    export LANG=C; export LC_ALL=C
    osx_install
elif [ -e /etc/alpine-release ]; then
    alpine_install
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # export LC_ALL='C.UTF-8'
    ubuntu_unstall
elif [ "$(expr substr $(uname -s) 1 9)" == "CYGWIN_NT" ]; then
    cygwin_install
fi


curl https://raw.githubusercontent.com/Jumpscale/developer/master/jsenv.sh?$RANDOM > ~/.jsenv.sh

source  ~/.jsenv.sh

mkdir -p $DATADIR
mkdir -p $CODEDIR
mkdir -p $CFGDIR

rm -rf ~/.ssh/known_hosts

mkdir -p $CODEDIR/github/jumpscale
cd $CODEDIR/github/jumpscale


if [ ! -e $CODEDIR/github/jumpscale/developer ]; then
    set +e
    git clone git@github.com:Jumpscale/developer.git
    if [ ! $? -eq 0 ]; then
        set -ex
        git clone https://github.com/Jumpscale/developer.git
    fi
    set +e
else
    cd $CODEDIR/github/jumpscale/developer
    git pull
fi

if [ ! -e $CODEDIR/github/jumpscale/core9 ]; then
    set +e
    git clone git@github.com:Jumpscale/core9.git
    if [ ! $? -eq 0 ]; then
        set -ex
        git clone https://github.com/Jumpscale/core9.git
    fi
    set +e
else
    cd $CODEDIR/github/jumpscale/core9
    git pull
fi

if [ ! -e $CODEDIR/github/jumpscale/lib9 ]; then
    set +e
    git clone git@github.com:Jumpscale/lib9.git
    if [ ! $? -eq 0 ]; then
        set -ex
        git clone https://github.com/Jumpscale/lib9.git
    fi
    set +e
else
    cd $CODEDIR/github/jumpscale/lib9
    git pull
fi

if [ ! -e $CODEDIR/github/jumpscale/ays9 ]; then
    set +e
    git clone git@github.com:Jumpscale/ays9.git
    if [ ! $? -eq 0 ]; then
        set -ex
        git clone https://github.com/Jumpscale/ays9.git
    fi
    set +e
else
    cd $CODEDIR/github/jumpscale/ays9
    git pull
fi

if [ ! -e $CODEDIR/github/jumpscale/rsal9 ]; then
    set +e
    git clone git@github.com:Jumpscale/rsal9.git
    if [ ! $? -eq 0 ]; then
        set -ex
        git clone https://github.com/Jumpscale/rsal9.git
    fi
    set +e
else
    cd $CODEDIR/github/jumpscale/rsal9
    git pull
fi

if [ ! -e $CODEDIR/github/jumpscale/portal9 ]; then
    set +e
    git clone git@github.com:Jumpscale/portal9.git
    if [ ! $? -eq 0 ]; then
        set -ex
        git clone https://github.com/Jumpscale/portal9.git
    fi
    set +e
else
    cd $CODEDIR/github/jumpscale/portal9
    git pull
fi


#link all our command lines relevant to jumpscale development env
rm -f /usr/local/bin/js*
rm -rf /usr/local/bin/cmds
find  $CODEDIR/github/jumpscale/developer/cmds -exec ln -s {} "/usr/local/bin/" \;
rm -rf /usr/local/bin/cmds
find  $CODEDIR/github/jumpscale/core9/cmds -exec ln -s {} "/usr/local/bin/" \;
rm -rf /usr/local/bin/cmds
