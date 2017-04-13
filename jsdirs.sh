
#this is the main bash file which has all configuration arguments, we want to work env arguments only
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

export SSHKEYNAME="SOMETHINGNOTTOUSE"

export DATADIR=$HOMEDIR/data
export CODEDIR=$HOMEDIR/code
export CFGDIR=$HOMEDIR/cfg

#is the base where jumpscale sandbox will be installed
export JSBASE=""

export JSGIT="https://github.com/Jumpscale/jumpscale_core9.git"
export JSBRANCH="master"
export AYSGIT="https://github.com/Jumpscale/ays_jumpscale"
export AYSBRANCH="master"

#USED for escalation
export EMAIL=""
export FULLNAME=""

#OUTGOING email server
##e.g. use www.endpulse.com (https://login.sendpulse.com/smtp/index/settings/)
export SMTP_SERVER="smtp-pulse.com"
export SMTP_SSL= 1
export SMTP_PORT= 465
export SMTP_LOGIN=""
export SMTP_PASSWD=""


ENDPULSE_KEY="
-----BEGIN PUBLIC KEY-----
...
-----END PUBLIC KEY-----"
