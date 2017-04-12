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
    brew unlink python3
    brew unlink git
    set -ex
    brew install python3
    brew link --overwrite python3
    brew install git
    brew link --overwrite git
}

if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform
    # echo 'install brew'
    export LANG=C; export LC_ALL=C
    osx_install
fi



curl https://raw.githubusercontent.com/Jumpscale/developer/master/env.sh?$RANDOM > ~/env.sh

source ~/env.sh

mkdir -p $DATADIR
mkdir -p $CODEDIR
mkdir -p $CFGDIR

rm -rf ~/.ssh/known_hosts

if [ ! -e $CODEDIR/github/jumpscale/developer ]; then
    mkdir -p $CODEDIR/github/jumpscale
    cd $CODEDIR/github/jumpscale
    set +ex
    git clone git@github.com:Jumpscale/developer.git
    if [ $? -eq 0 ]; then
        set -ex
        git clone https://github.com/Jumpscale/developer.git
    fi
    set -ex
else
    cd $CODEDIR/github/jumpscale/developer
    git pull
fi

#cd developer/scripts
#sh prepare.sh #only need to do this once
#sh js_builder.sh

