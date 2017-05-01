set -e
clear
if ! type "curl" > /dev/null; then
  echo "curl is not installed, please install"
  exit 1
fi

function valid() {
  EXITCODE=$?
  if [ ${EXITCODE} -ne 0 ]; then
      cat /tmp/lastcommandoutput.txt
      if [ -z $1 ]; then
        echo "Error in last step"
      else
        echo $1
      fi
      exit ${EXITCODE}
  fi
}

function osx_install {

    if ! type "brew" > /dev/null; then
      sudo echo "* Install Brew"
      yes '' | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    set +e
    sudo echo "* Unlink curl/python/git"
    brew unlink curl   > /tmp/lastcommandoutput.txt 2>&1
    brew unlink python3  > /tmp/lastcommandoutput.txt 2>&1
    brew unlink git  > /tmp/lastcommandoutput.txt 2>&1
    set -e
    sudo echo "* Install Python"
    brew install --overwrite python3  > /tmp/lastcommandoutput.txt 2>&1
    valid
    brew link --overwrite python3  > /tmp/lastcommandoutput.txt 2>&1
    valid
    sudo echo "* Install Git"
    brew install git  > /tmp/lastcommandoutput.txt 2>&1
    valid
    brew link --overwrite git  > /tmp/lastcommandoutput.txt 2>&1
    valid
    sudo echo "* Install Curl"
    brew install curl  > /tmp/lastcommandoutput.txt 2>&1
    valid
    brew link --overwrite curl  > /tmp/lastcommandoutput.txt 2>&1
    valid

    # brew install snappy
    # sudo mkdir -p /optvar
    # sudo chown -R $USER /optvar
    # sudo mkdir -p /opt
    # sudo chown -R $USER /opt
}


function alpine_install {
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

function getcode {

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
}


########MAIN BLOCK#############

sudo echo "* get mascot"
curl https://raw.githubusercontent.com/Jumpscale/developer/master/mascot?$RANDOM > ~/.mascot.txt
valid
clear
cat ~/.mascot.txt
echo

if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform
    echo "* INSTALL homebrew, curl, python, git"
    export LANG=C; export LC_ALL=C
    osx_install
elif [ -e /etc/alpine-release ]; then
    echo "* INSTALL curl, python, git"
    alpine_install
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # export LC_ALL='C.UTF-8'
    echo "* INSTALL curl, python, git"
    ubuntu_unstall
elif [ "$(expr substr $(uname -s) 1 9)" == "CYGWIN_NT" ]; then
    cygwin_install
fi

sudo echo "* get gig environment script"
curl https://raw.githubusercontent.com/Jumpscale/developer/master/jsenv.sh?$RANDOM > ~/.jsenv.sh
valid


echo "* include the gig environment script"
source  ~/.jsenv.sh
#THIS GIVES GIG & CODEDIR

#check profile file exists, if yes modify
if [ ! -e $HOMEDIR/.bash_profile ] ; then
    touch $HOMEDIR/.bash_profile
else
    #make a 1time backup
    if [ ! -e "$HOMEDIR/.bash_profile.bak" ]; then
        cp $HOMEDIR/.bash_profile  $HOMEDIR/.bash_profile.bak
    fi
fi

set -e
sed  '/export SSHKEYNAME/d'  $HOMEDIR/.bash_profile > $HOMEDIR/.bash_profile2
mv $HOMEDIR/.bash_profile2 $HOMEDIR/.bash_profile
sed  '/jsenv.sh/d'  $HOMEDIR/.bash_profile > $HOMEDIR/.bash_profile2
mv $HOMEDIR/.bash_profile2 $HOMEDIR/.bash_profile
echo 'export SSHKEYNAME=$SSHKEYNAME' >> $HOMEDIR/.bash_profile
echo 'source ~/.jsenv.sh' >> $HOMEDIR/.bash_profile


echo "* create dir's"
export CODEDIR="$GIGDIR/code"
mkdir -p $CODEDIR/github/jumpscale > /tmp/lastcommandoutput.txt 2>&1
valid

echo "* get core code for development scripts & jumpscale core"
getcode > /tmp/lastcommandoutput.txt 2>&1
valid

function linkcode {
    echo "* link commands to local environment"
    #link all our command lines relevant to jumpscale development env
    rm -f /usr/local/bin/js9*
    rm -rf /usr/local/bin/cmds*
    find  $CODEDIR/github/jumpscale/developer/cmds_host -exec ln -s {} "/usr/local/bin/" \;
    rm -rf /usr/local/bin/cmds_host
}

linkcode > /tmp/lastcommandoutput.txt 2>&1
valid

#create private dir
mkdir -p $GIGDIR/private
if [ ! -e "$GIGDIR/private/me.toml" ]; then
    echo "* copy templates private files."
    cp $CODEDIR/github/jumpscale/developer/templates/private/me.toml $GIGDIR/private/ > /tmp/lastcommandoutput.txt 2>&1
    valid
fi
echo "* copy chosen sshpub key"
mkdir -p $GIGDIR/private/pubsshkeys
cp ~/.ssh/$SSHKEYNAME.pub $GIGDIR/private/pubsshkeys/ > /tmp/lastcommandoutput.txt 2>&1
valid


echo "* please edit templates in $GIGDIR/private/, if you don't then installer will ask for it."
echo "* to get started with jumpscale do 'js9_start', docker needs to be installed locally."
