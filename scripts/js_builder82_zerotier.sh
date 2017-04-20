#!/bin/bash

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

if (( `docker ps -a | grep js82 | wc -l` > 0 )); then
  echo "Cleaning up existing container instance"
  docker rm --force js82 > /tmp/lastcommandoutput.txt 2>&1
  valid
fi

if [ -z $1 ]; then
  echo "Usage: js82_builder_zerotier.sh <ZEROTIERNWID>"
  echo
  echo "  ZEROTIERNWID: The zerotier network in which the jumpscale should join."
  echo
  exit 1
fi
ZEROTIERNWID=$1

if [ -e /proc/version ] && grep -q Microsoft /proc/version; then
  # Windows subsystem 4 linux
  WINDOWSUSERNAME=`ls -ail /mnt/c/Users/ | grep drwxrwxrwx | grep -v Public | grep -v Default | grep -v '\.\.'`
  WINDOWSUSERNAME=${WINDOWSUSERNAME##* }
  GIGHOME=/mnt/c/Users/${WINDOWSUSERNAME}/gig
else
  # Native Linux or MacOSX
  GIGHOME=~/gig
fi
mkdir -p ${GIGHOME}/data > /tmp/lastcommandoutput.txt 2>&1
valid
mkdir -p ${GIGHOME}/code > /tmp/lastcommandoutput.txt 2>&1
valid
mkdir -p ${GIGHOME}/zerotier-one > /tmp/lastcommandoutput.txt 2>&1
valid
# Test if current user can write in the mounted directories
touch ${GIGHOME}/data/.write_test > /tmp/lastcommandoutput.txt 2>&1
valid "Aborting! Docker needs to have write access in your mounted directories.\n Could not write to ${OPTVAR}/data/.write_test"
rm ${GIGHOME}/data/.write_test > /tmp/lastcommandoutput.txt 2>&1
touch ${GIGHOME}/zerotier-one/.write_test > /tmp/lastcommandoutput.txt 2>&1
valid "Aborting! Docker needs to have write access in your mounted directories.\n Could not write to ${OPTVAR}/zerotier-one/.write_test"
rm ${GIGHOME}/zerotier-one/.write_test > /tmp/lastcommandoutput.txt 2>&1
touch ${GIGHOME}/code/.write_test > /tmp/lastcommandoutput.txt 2>&1
valid "Aborting! Docker needs to have write access in your mounted directories.\n Could not write to ${OPTVAR}/zerotier-one/.write_test"
rm ${GIGHOME}/code/.write_test > /tmp/lastcommandoutput.txt 2>&1
if [ -e /proc/version ] && grep -q Microsoft /proc/version; then
  # Windows subsystem 4 linux
  GIGHOME=c:/Users/${WINDOWSUSERNAME}/gig
fi

echo "Starting docker container"
docker run --name js82 -h js82 -d --device=/dev/net/tun --cap-add=NET_ADMIN --cap-add=SYS_ADMIN -v ${GIGHOME}/zerotier-one/:/var/lib/zerotier-one/ -v ${GIGHOME}/code/:/opt/code/ -v ${GIGHOME}/data/:/optvar/data zerotier/zerotier-containerized > /tmp/lastcommandoutput.txt 2>&1
valid

echo "Joining zerotier network"
docker exec -t js82 /bin/sh -c "/zerotier-cli join ${ZEROTIERNWID}" > /tmp/lastcommandoutput.txt 2>&1
valid
echo "Waiting for ip in zerotier network (do not forget to allow the container in your network, and make sure auto assign ip is enabled) ..."
while :
do
  sleep 1
  ZEROTIERIP=`docker exec -t js82 /bin/sh -c "ip -4 addr show zt0 | grep -oE 'inet\s\d+(\.\d+){3}' | sed 's/inet //'"`
  if [ "${ZEROTIERIP}" ]; then
    echo "Container zerotier ip = ${ZEROTIERIP}"
    break
  fi
done

echo "Installing jumpscale dependencies"
docker exec -t js82 /bin/sh -c "echo 'http://dl-cdn.alpinelinux.org/alpine/v3.5/main' > /etc/apk/repositories" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js82 /bin/sh -c "echo 'http://dl-cdn.alpinelinux.org/alpine/v3.5/community' >> /etc/apk/repositories" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js82 /bin/sh -c "apk update; apk upgrade; apk add curl mc bash openssh-client openssh" > /tmp/lastcommandoutput.txt 2>&1
valid

echo "Configuring ssh access"
docker exec -t js82 /bin/sh -c "/usr/bin/ssh-keygen -A" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js82 /bin/sh -c "/usr/sbin/sshd" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js82 /bin/sh -c "mkdir /root/.ssh"> /tmp/lastcommandoutput.txt 2>&1
valid
for i in `ls ~/.ssh/*.pub`
do
  KEY=`cat ${i}`
  docker exec -t js82 /bin/sh -c "echo ${KEY} >> /root/.ssh/authorized_keys" > /tmp/lastcommandoutput.txt 2>&1
  valid
done
if [ -e /proc/version ] && grep -q Microsoft /proc/version; then
  for i in `ls /mnt/c/Users/${WINDOWSUSERNAME}/.ssh/*.pub`
  do
    KEY=`cat ${i}`
    docker exec -t js82 /bin/sh -c "echo ${KEY} >> /root/.ssh/authorized_keys" > /tmp/lastcommandoutput.txt 2>&1
    valid
  done
fi
ssh-keygen -f ~/.ssh/known_hosts -R ${ZEROTIERIP} > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js82 /bin/sh -c 'echo "JSDEVELOPER WELCOME" > /etc/motd' > /tmp/lastcommandoutput.txt 2>&1
valid

echo "Downloading and building jumpscale 8.2"
docker exec -t js82 /bin/sh -c 'cd $TMPDIR;rm -f install.sh;export JSBRANCH="8.2.0";curl -k https://raw.githubusercontent.com/Jumpscale/jumpscale_core8/$JSBRANCH/install/install.sh?$RANDOM > install.sh; bash install.sh' > /tmp/lastcommandoutput.txt 2>&1
valid

#echo "Append the following lines to your .bashrc file to interact easily with jumpscale and ays"
echo "alias js82='docker exec -it js82 js'" >> ~/.bashrc
echo "alias ays82='docker exec -it js82 ays'" >> ~/.bashrc
echo "alias js82bash='docker exec -it js82 bash'" >> ~/.bashrc

echo
echo "Congratulations, your docker based jumpscale installation is ready!"
echo "Sandbox is present in the zerotier network ${ZEROTIERNWID} with ip: ${ZEROTIERIP}"
echo "run js82, ays82, or js82bash in a new shell to work in your sandbox"
echo "ssh into your sandbox through ssh root@${ZEROTIERIP}"
