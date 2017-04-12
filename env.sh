
#this is the main env file which needs to be sourced for any action we do on our platform

if [ "$(uname)" == "Darwin" ]; then
    export LANG=C; export LC_ALL=C
    export HOMEDIR=~
    export TMPDIR=$TMPDIR
elif grep -q Microsoft /proc/version; then
    # Windows subsystem 4 linux
    WINDOWSUSERNAME=`ls -ail /mnt/c/Users/ | grep drwxrwxrwx | grep -v Public | grep -v Default | grep -v '\.\.'`
    WINDOWSUSERNAME=${WINDOWSUSERNAME##* }
    export HOMEDIR=/mnt/c/Users/${WINDOWSUSERNAME}
else
    # Native Linux or MacOSX
    export HOMEDIR=~
    export TMPDIR=$TMPDIR
fi

#can overrule if you want
#export TMPDIR=/tmp
#export HOMEDIR=~

###############################################################

if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent`
fi

if [ -e $HOMEDIR/.ssh/id_rsa.pub ]; then
    export SSHKEYNAME='id_rsa'
fi

if [ -z "$SSHKEYNAME" ]; then
    echo "Need to set SSHKEYNAME (through export SSHKEYNAME='mykey')"
    exit 1
fi

ssh-add $HOMEDIR/.ssh/$SSHKEYNAME

export DATADIR=$HOMEDIR/data
export CODEDIR=$HOMEDIR/code
export CFGDIR=$HOMEDIR/cfg
