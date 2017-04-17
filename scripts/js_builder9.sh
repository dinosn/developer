#/bin/bash
docker rm --force js9
mkdir -p /optvar/data

set -ex

if [ -z "$SSHKEYNAME" ]; then
    echo "Need to set SSHKEYNAME (through export SSHKEYNAME='mykey')"
    exit 1
fi

rm -rf ~/.ssh/known_hosts

docker run --name js9 -h js9 -d -p 2223:22 -v ~/.ssh/$SSHKEYNAME.pub:/root/.ssh/authorized_keys -v $CODEDIR:/opt/code/ -v $DATADIR:/data macropin/sshd

sleep 1

ssh root@localhost -p 2223 'apk update;apk add curl;apk add mc;apk add python3'
ssh root@localhost -p 2223 'cd $TMPDIR;rm -rf get-pip.py;curl -k https://bootstrap.pypa.io/get-pip.py > get-pip.py;python3 get-pip.py'
ssh root@localhost -p 2223 'pip3 install --upgrade pip'
ssh root@localhost -p 2223 'pip3 install -e /opt/code/github/jumpscale/core9 --upgrade'

ssh root@localhost -p 2223 'python3 -c "from JumpScale9 import j"'

ssh -A root@localhost -p 2223 'echo "JS9 DEVELOPER WELCOME." > /etc/motd'
