#/bin/bash

function valid () {
  if [ $? -ne 0 ]; then
      if [ -z $1 ]; then
        echo
        echo
        echo "Error in last step (see * ... above)"
        echo
      else
        echo
        echo
        echo "Error in last step (see * ... above):"
        echo $1
        echo
      fi
      cat /tmp/lastcommandoutput.txt
      exit $?
  fi
}

clear
cat ~/.mascot.txt


if [ -z $1 ]; then
    # echo "Usage: js_builder9.sh <ZEROTIERNWID>"
    # echo
    # echo "  ZEROTIERNWID: The zerotier network in which the jumpscale should join."
    # echo
    # exit 1
    echo
    echo "WARNING: WILL NOT USE A ZEROTIER CONNECTION !"
    echo "If you want to use zerotier do: jsinstall <ZEROTIERNWID>"
    echo
else
    echo "* Create zerotier-one dir."
    mkdir -p ${GIGHOME}/zerotier-one > /tmp/lastcommandoutput.txt 2>&1
    valid
    ZEROTIERNWID=$1
fi

function cleanup {
    if (( `docker ps -a | grep js9 | wc -l` > 0 )); then
      echo "* Cleaning up existing container instance"
      docker rm --force js9 > /tmp/lastcommandoutput.txt 2>&1
      valid "please make sure docker is properly installed."
    fi
}
cleanup

if [ -z "$SSHKEYNAME" ]; then
    echo "Need to set SSHKEYNAME (through export SSHKEYNAME='mykey')"
    exit 1
fi

if [ -z "$GIGHOME" ]; then
    echo "Please execute: init instructions in https://github.com/Jumpscale/developer"
    echo "and restart shell."
    exit 1
fi

if [ -z "$CODEDIR" ]; then
    echo "Please execute: init instructions in https://github.com/Jumpscale/developer"
    echo "and restart shell."
    exit 1
fi

rm -rf ~/.ssh/known_hosts



echo "* Starting docker container"
docker run --name js9 -h js9 -d -p 2223:22 --device=/dev/net/tun --cap-add=NET_ADMIN --cap-add=SYS_ADMIN -v ${GIGHOME}/zerotier-one/:/var/lib/zerotier-one/ -v ${GIGHOME}/code/:/opt/code/ -v ${GIGHOME}/data/:/data zerotier/zerotier-containerized > /tmp/lastcommandoutput.txt 2>&1
valid

echo "* Installing base system packages (can take a while)"
docker exec -t js9 /bin/sh -c "echo 'http://dl-cdn.alpinelinux.org/alpine/v3.5/main' > /etc/apk/repositories" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js9 /bin/sh -c "echo 'http://dl-cdn.alpinelinux.org/alpine/v3.5/community' >> /etc/apk/repositories" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js9 /bin/sh -c "apk update; apk upgrade; apk add curl bash openssh-client openssh" > /tmp/lastcommandoutput.txt 2>&1
valid

echo "* Configuring ssh access"
docker exec -t js9 /bin/sh -c "/usr/bin/ssh-keygen -A" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js9 /bin/sh -c "/usr/sbin/sshd" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js9 /bin/sh -c "mkdir /root/.ssh"> /tmp/lastcommandoutput.txt 2>&1
valid

if [ -e /proc/version ] && grep -q Microsoft /proc/version; then
  for i in `ls /mnt/c/Users/${WINDOWSUSERNAME}/.ssh/*.pub`
  do
    KEY=`cat ${i}`
    docker exec -t js9 /bin/sh -c "echo ${KEY} >> /root/.ssh/authorized_keys" > /tmp/lastcommandoutput.txt 2>&1
    valid
  done
else
    KEY=`cat $HOMEDIR/.ssh/$SSHKEYNAME.pub`
    docker exec -t js9 /bin/sh -c "echo ${KEY} >> /root/.ssh/authorized_keys" > /tmp/lastcommandoutput.txt 2>&1
    valid
fi

if [ ! -z "$ZEROTIERNWID" ]; then
    echo "* Joining zerotier network"
    docker exec -t js9 /bin/sh -c "/zerotier-cli join ${ZEROTIERNWID}" > /tmp/lastcommandoutput.txt 2>&1
    valid
    echo "* Waiting for ip in zerotier network (do not forget to allow the container in your network, and make sure auto assign ip is enabled) ..."
    while :
    do
      sleep 1
      ZEROTIERIP=`docker exec -t js9 /bin/sh -c "ip -4 addr show zt0 | grep -oE 'inet\s\d+(\.\d+){3}' | sed 's/inet //'"`
      if [ "${ZEROTIERIP}" ]; then
        echo "* !!! Zerotier Network ID = $ZEROTIERNWID   !!!"
        echo "* !!! Container zerotier ip = ${ZEROTIERIP} !!!"
        break
      else
        echo "  .. no ip yet: ${ZEROTIERIP}"
      fi
    done
fi

# ssh-keygen -f ~/.ssh/known_hosts -R ${ZEROTIERIP} > /tmp/lastcommandoutput.txt 2>&1
# valid

echo "* Installing js dependencies (can take a while)"
docker exec -t js9 /bin/sh -c "echo 'http://dl-cdn.alpinelinux.org/alpine/v3.5/main' > /etc/apk/repositories" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js9 /bin/sh -c "echo 'http://dl-cdn.alpinelinux.org/alpine/v3.5/community' >> /etc/apk/repositories" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js9 /bin/sh -c "apk update; apk upgrade; apk add python3 mc tmux" > /tmp/lastcommandoutput.txt 2>&1
valid

echo "* update python pip"
docker exec -t js9 /bin/sh -c 'cd $TMPDIR;rm -rf get-pip.py;curl -k https://bootstrap.pypa.io/get-pip.py > get-pip.py;python3 get-pip.py' > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js9 /bin/sh -c 'pip3 install --upgrade pip' > /tmp/lastcommandoutput.txt 2>&1
valid

docker exec -t js9 /bin/sh -c 'echo "JS9 DEVELOPER WELCOME." > /etc/motd' > /tmp/lastcommandoutput.txt 2>&1
valid

echo "* install jumpscale 9 from pip"
docker exec -t js9 /bin/sh -c 'pip3 install -e /opt/code/github/jumpscale/core9 --upgrade' > /tmp/lastcommandoutput.txt 2>&1
valid

echo "* first init of jumpscale 9"
docker exec -t js9 /bin/sh -c 'python3 -c "from JumpScale import j;j.do.initEnv()"' > /tmp/lastcommandoutput.txt 2>&1 #need to do it twice, ignore error first time
docker exec -t js9 /bin/sh -c 'python3 -c "from JumpScale import j"' > /tmp/lastcommandoutput.txt 2>&1
valid

echo "* install done"
echo
