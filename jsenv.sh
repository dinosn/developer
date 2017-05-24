
#this is the main env file which needs to be sourced for any action we do on our platform


clear

# cat ~/gig/.mascot.txt

set -e

if [ "$(uname)" = "Darwin" ]; then
    export LANG=C; export LC_ALL=C
    export HOMEDIR=~

elif grep -q Microsoft /proc/version; then
    # Windows subsystem 4 linux
    WINDOWSUSERNAME=$(ls -ail /mnt/c/Users/ | grep drwxrwxrwx | grep -v Public | grep -v Default | grep -v '\.\.')
    WINDOWSUSERNAME=${WINDOWSUSERNAME##* }
    GIGDIR=/mnt/c/Users/${WINDOWSUSERNAME}/gig

else
    # Native Linux or MacOSX
    export GIGDIR=${GIGDIR:-~/gig}
    HOMEDIR=~
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

while [ ! -e "$HOMEDIR/.ssh/$SSHKEYNAME" ] || [ "$SSHKEYNAME" = "" ]
do
    echo "please give name of ssh key to load, if not generate one."
    read -p 'SSHKEYNAME: ' SSHKEYNAME
    echo "check keypath '$HOMEDIR/.ssh/$SSHKEYNAME' exists"
done

if ! ssh-add -l | grep -q $SSHKEYNAME; then
    echo "will now try to load sshkey: $HOMEDIR/.ssh/$SSHKEYNAME"
    ssh-add $HOMEDIR/.ssh/$SSHKEYNAME
    echo "ssh key $SSHKEYNAME loaded"
fi


export GIGDIR="$GIGDIR"
export CODEDIR="$GIGDIR/code"

export PS1="gig:\h:\w$\[$(tput sgr0)\]"

set +ex
