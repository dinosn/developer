set -ex

if [ -z "$SSHKEYNAME" ]; then
    echo "Need to set SSHKEYNAME (through export SSHKEYNAME='mykey')"
    exit 1
fi
    
if grep -q Microsoft /proc/version; then
    # Windows subsystem 4 linux
    WINDOWSUSERNAME=`ls -ail /mnt/c/Users/ | grep drwxrwxrwx | grep -v Public | grep -v Default | grep -v '\.\.'`
    WINDOWSUSERNAME=${WINDOWSUSERNAME##* }
    OPTVAR=/mnt/c/Users/${WINDOWSUSERNAME}/optvar
    OPT=/mnt/c/Users/${WINDOWSUSERNAME}/opt
else
    # Native Linux or MacOSX
    export OPTVAR=/optvar
    export OPT=/opt
fi

mkdir -p ${OPTVAR}/data
mkdir -p ${OPT}/data

rm -rf ~/.ssh/known_hosts

mkdir -p ${OPT}/code/github/jumpscale

cd ${OPT}/code/github/jumpscale
rm -rf developer
git clone git@github.com:Jumpscale/developer.git

cd developer/scripts

sh prepare.sh #only need to do this once
sh js_builder.sh
