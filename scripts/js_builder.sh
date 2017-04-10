#/bin/bash
docker rm --force js8
mkdir -p /optvar/data

set -ex

if [ -z "$SSHKEYNAME" ]; then
    echo "Need to set SSHKEYNAME (through export SSHKEYNAME='mykey')"
    exit 1
fi

rm -rf /Users/despiegk/.ssh/known_hosts

docker run --name js8 -h js8 -d -p 2222:22 -v ~/.ssh/$SSHKEYNAME.pub:/root/.ssh/authorized_keys -v /opt/code/:/opt/code/ -v ~/data/:/optvar/data macropin/sshd

sleep 1

ssh root@localhost -p 2222 'apk update;apk add curl;apk add mc'

# #capnp needs to be installed before doing jumpscale
# scp -P 2222 helpers/capnp.sh root@localhost:/tmp/
# ssh -A root@localhost -p 2222 'cd /tmp;sh capnp.sh'

#important to use local keys
ssh -A root@localhost -p 2222 'cd $TMPDIR;rm -f install.sh;export JSBRANCH="8.2.0";curl -k https://raw.githubusercontent.com/Jumpscale/jumpscale_core8/$JSBRANCH/install/install.sh?$RANDOM > install.sh; bash install.sh'
