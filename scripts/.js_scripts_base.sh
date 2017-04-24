set +ex
clear

function valid () {
  if [ $? -ne 0 ]; then
      cat /tmp/lastcommandoutput.txt
      if [ -z $1 ]; then
        echo "Error in last step"
      else
        echo $1
      fi
      exit $?
  fi
}

function getcode {
    source ~/.jsenv.sh

    echo $CODEDIR/github/jumpscale/$1
    if [ ! -e $CODEDIR/github/jumpscale/$1 ]; then
        set +e
        git clone git@github.com:Jumpscale/$1.git
        if [ ! $? -eq 0 ]; then
            set -ex
            git clone https://github.com/Jumpscale/$1.git
        fi
        set +e
    else
        cd $CODEDIR/github/jumpscale/$1
        git pull
    fi
}

cat ~/.mascot.txt
echo
