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


if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform
    # echo 'install brew'
    export LANG=C; export LC_ALL=C
    osx_install
fi



curl https://raw.githubusercontent.com/Jumpscale/developer/master/jsenv.sh?$RANDOM > ~/jsenv.sh

source ~/jsenv.sh

mkdir -p $DATADIR
mkdir -p $CODEDIR
mkdir -p $CFGDIR

rm -rf ~/.ssh/known_hosts

if [ ! -e $CODEDIR/github/jumpscale/developer ]; then
    mkdir -p $CODEDIR/github/jumpscale
    cd $CODEDIR/github/jumpscale
    set +e
    git clone git@github.com:Jumpscale/developer.git
    if [ ! $? -eq 0 ]; then
        set -ex
        git clone https://github.com/Jumpscale/developer.git
    fi
    set -ex
else
    cd $CODEDIR/github/jumpscale/developer
    git pull
fi

#link all our command lines relevant to jumpscale development env
rm -f /usr/local/bin/js*
rm -rf /usr/local/bin/cmds
find  $CODEDIR/github/jumpscale/developer/cmds -exec ln -s {} "/usr/local/bin/" \;
rm -rf /usr/local/bin/cmds
