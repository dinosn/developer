
#this is the main env file which needs to be sourced for any action we do on our platform


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

clear

cat ~/.mascot.txt

set -e

if [ -e /proc/version ] && grep -q Microsoft /proc/version; then
  # Windows subsystem 4 linux
  WINDOWSUSERNAME=`ls -ail /mnt/c/Users/ | grep drwxrwxrwx | grep -v Public | grep -v Default | grep -v '\.\.'`
  WINDOWSUSERNAME=${WINDOWSUSERNAME##* }
  GIGHOME=/mnt/c/Users/${WINDOWSUSERNAME}/gig
else
  # Native Linux or MacOSX
  GIGHOME=~/gig
fi

if [ "$(uname)" == "Darwin" ]; then
    export LANG=C; export LC_ALL=C
    export HOMEDIR=~
elif grep -q Microsoft /proc/version; then
      # Windows subsystem 4 linux
      WINDOWSUSERNAME=`ls -ail /mnt/c/Users/ | grep drwxrwxrwx | grep -v Public | grep -v Default | grep -v '\.\.'`
      WINDOWSUSERNAME=${WINDOWSUSERNAME##* }
      GIGHOME=/mnt/c/Users/${WINDOWSUSERNAME}/gig
else
    # Native Linux or MacOSX
    export GIGHOME=~/gig
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
    echo " sshkey $SSHKEYNAME is loaded."
else
    set -e
    echo "will now try to load sshkey: $HOMEDIR/.ssh/$SSHKEYNAME"
    ssh-add $HOMEDIR/.ssh/$SSHKEYNAME
    echo "ssh key loaded"
fi


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
echo export SSHKEYNAME=$SSHKEYNAME >> $HOMEDIR/.bash_profile
echo source ~/.jsenv.sh >> $HOMEDIR/.bash_profile

#now add to profile

export TMPDIR="/tmp"
export BASEDIR="$GIGHOME/js9"
export VARDIR="$GIGHOME/var"
export CFGDIR="$GIGHOME/cfg"
export DATADIR="$GIGHOME/data"
export CODEDIR="$GIGHOME/code"
export BUILDDIR="$VARDIR/build"
export LIBDIR="$BASEDIR/lib"
export TEMPLATEDIR="$GIGHOME/templates"

set +e

export PS1="gig:\h:\w$\[$(tput sgr0)\]"
