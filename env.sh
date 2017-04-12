
#this is the main env file which needs to be sourced for any action we do on our platform
set -ex

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


if [ -z $SSHKEYNAME]; then
    SSHKEYNAME=SOMETHINGWHICHWILLNOTMATCH
else
    #trim the sshkeyname
    export SSHKEYNAME=`echo $SSHKEYNAME | xargs`
fi

while [ ! -e "$HOMEDIR/.ssh/$SSHKEYNAME" ]
do
    echo "please give name of ssh key to load, if not generate yet do so."
    read -p 'SSHKEYNAME: ' SSHKEYNAME
    echo "check keypath '$HOMEDIR/.ssh/$SSHKEYNAME' exists"

done

set +e
keyexists=$(ssh-add -l| grep $SSHKEYNAME)
#check exit code if not 0 then means key did not exist
if [ $? -eq 0 ]; then
    set -e
    echo "KEY $SSHKEYNAME was loaded"
else
    set -e
    echo "will now try to load sshkey: $HOMEDIR/.ssh/$SSHKEYNAME"
    ssh-add $HOMEDIR/.ssh/$SSHKEYNAME
    echo "KEY loaded"
fi


#check profile file exists, if yes modify
if [ -e ~/.profile ] ; then
    sed  '/export SSHKEYNAME/d'  ~/.profile > ~/.profile2;mv ~/.profile2 ~/.profile
    sed  '/source ~/env.sh'  ~/.profile > ~/.profile2;mv ~/.profile2 ~/.profile
    echo export SSHKEYNAME=$SSHKEYNAME >> ~/.profile
    echo source ~/env.sh >> ~/.profile
fi

#now add to profile

export DATADIR=$HOMEDIR/data
export CODEDIR=$HOMEDIR/code
export CFGDIR=$HOMEDIR/cfg
