
#this is the main env file which needs to be sourced for any action we do on our platform


function valid () {
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

clear

# cat ~/gig/.mascot.txt

set -e

if [ -e /proc/version ] && grep -q Microsoft /proc/version; then
  # Windows subsystem 4 linux
  WINDOWSUSERNAME=`ls -ail /mnt/c/Users/ | grep drwxrwxrwx | grep -v Public | grep -v Default | grep -v '\.\.'`
  WINDOWSUSERNAME=${WINDOWSUSERNAME##* }
  GIGDIR=/mnt/c/Users/${WINDOWSUSERNAME}/gig
else
  # Native Linux or MacOSX
  GIGDIR=~/gig
fi

if [ "$(uname)" == "Darwin" ]; then
    export LANG=C; export LC_ALL=C
    export HOMEDIR=~
elif grep -q Microsoft /proc/version; then
      # Windows subsystem 4 linux
      WINDOWSUSERNAME=`ls -ail /mnt/c/Users/ | grep drwxrwxrwx | grep -v Public | grep -v Default | grep -v '\.\.'`
      WINDOWSUSERNAME=${WINDOWSUSERNAME##* }
      GIGDIR=/mnt/c/Users/${WINDOWSUSERNAME}/gig
else
    # Native Linux or MacOSX
    export GIGDIR=~/gig
fi

#can overrule if you want
#export TMPDIR=/tmp
#export HOMEDIR=~

###############################################################

if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent`
fi

# echo "KEYNAME:$SSHKEYNAME"
if [ -z $SSHKEYNAME ]; then
    SSHKEYNAME=SOMETHINGWHICHWILLNOTMATCH
else
    #trim the sshkeyname
    export SSHKEYNAME=`echo $SSHKEYNAME | xargs`
fi

while [ ! -e "$HOMEDIR/.ssh/$SSHKEYNAME" ]
do
    echo "please give name of ssh key to load, if not generate one."
    read -p 'SSHKEYNAME: ' SSHKEYNAME
    echo "check keypath '$HOMEDIR/.ssh/$SSHKEYNAME' exists"
done

set +e
keyexists=$(ssh-add -l| grep $SSHKEYNAME)
#check exit code if not 0 then means key did not exist
if [ $? -eq 0 ]; then
    set -e
    # echo "                                                                                       sshkey $SSHKEYNAME loaded."
else
    set -e
    echo "will now try to load sshkey: $HOMEDIR/.ssh/$SSHKEYNAME"
    ssh-add $HOMEDIR/.ssh/$SSHKEYNAME
    echo "ssh key $SSHKEYNAME loaded"
fi


export GIGDIR="$GIGDIR"
export CODEDIR="$GIGDIR/code"

# export TMPDIR="/tmp"
# export BASEDIR="$GIGDIR/gig"
# export VARDIR="$GIGDIR/var"
# export CFGDIR="$GIGDIR/cfg"
# export DATADIR="$GIGDIR/data"
# export BUILDDIR="$VARDIR/build"
# export LIBDIR="$BASEDIR/lib"
# export TEMPLATEDIR="$GIGDIR/templates"

set +e

export PS1="gig:\h:\w$\[$(tput sgr0)\]"
