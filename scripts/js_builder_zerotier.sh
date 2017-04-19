#/bin/bash
function valid () {
  if [ $? -ne 0 ]; then
      cat /tmp/lastcommandoutput.txt
      echo "Error in last step"
      exit $?
  fi
}

if (( `docker ps -a | grep js8 | wc -l` > 0 )); then
  echo "Cleaning up existing container instance"
  docker rm --force js8 > /tmp/lastcommandoutput.txt 2>&1
  valid
fi

if [ "$1" ]; then
  ZEROTIERNWID=$1
fi
if [ -z "${ZEROTIERNWID}" ]; then
  echo "Need to pass zerotier networkid  or set ZEROTIERNWID (through export ZEROTIERNWID='my zerotier network')"
  exit 1
fi

if [ -e /proc/version ] && grep -q Microsoft /proc/version; then
  # Windows subsystem 4 linux
  WINDOWSUSERNAME=`ls -ail /mnt/c/Users/ | grep drwxrwxrwx | grep -v Public | grep -v Default | grep -v '\.\.'`
  WINDOWSUSERNAME=${WINDOWSUSERNAME##* }
  OPTVAR=/mnt/c/Users/${WINDOWSUSERNAME}/optvar
  OPT=/mnt/c/Users/${WINDOWSUSERNAME}/opt
else
  # Native Linux or MacOSX
  OPTVAR=/optvar
  OPT=/opt
fi
mkdir -p ${OPTVAR}/data > /tmp/lastcommandoutput.txt 2>&1
valid
mkdir -p ${OPT}/code > /tmp/lastcommandoutput.txt 2>&1
valid
mkdir -p ${OPTVAR}/zerotier-one  > /tmp/lastcommandoutput.txt 2>&1
valid
if [ -e /proc/version ] && grep -q Microsoft /proc/version; then
  # Windows subsystem 4 linux
  OPTVAR=c:/Users/${WINDOWSUSERNAME}/optvar
  OPT=c:/Users/${WINDOWSUSERNAME}/opt
fi

echo "Starting docker container"
docker run --name js8 -h js8 -d --device=/dev/net/tun --cap-add=NET_ADMIN --cap-add=SYS_ADMIN -v ${OPTVAR}/zerotier-one/:/var/lib/zerotier-one/ -v ${OPT}/code/:/opt/code/ -v ${OPTVAR}/data/:/optvar/data zerotier/zerotier-containerized > /tmp/lastcommandoutput.txt 2>&1
valid

echo "Joining zerotier network"
docker exec -it js8 /bin/sh -c "/zerotier-cli join ${ZEROTIERNWID}" > /tmp/lastcommandoutput.txt 2>&1
valid
echo "Waiting for ip in zerotier network (do not forget to allow the container in your network, and make sure auto assign ip is enabled) ..."
while :
do
  sleep 1
  ZEROTIERIP=`docker exec -it js8 /bin/sh -c "ip -4 addr show zt0 | grep -oE 'inet\s\d+(\.\d+){3}' | sed 's/inet //'"`
  if [ "${ZEROTIERIP}" ]; then
    echo "Container zerotier ip = ${ZEROTIERIP}"
    break
  fi
done

echo "Installing jumpscale dependencies"
docker exec -it js8 /bin/sh -c "echo 'http://dl-cdn.alpinelinux.org/alpine/v3.5/main' > /etc/apk/repositories" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -it js8 /bin/sh -c "echo 'http://dl-cdn.alpinelinux.org/alpine/v3.5/community' >> /etc/apk/repositories" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -it js8 /bin/sh -c "apk update; apk upgrade; apk add curl mc bash openssh-client openssh" > /tmp/lastcommandoutput.txt 2>&1
valid

echo "Configuring ssh access"
docker exec -it js8 /bin/sh -c "/usr/bin/ssh-keygen -A" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -it js8 /bin/sh -c "/usr/sbin/sshd" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -it js8 /bin/sh -c "mkdir /root/.ssh"> /tmp/lastcommandoutput.txt 2>&1
valid
for i in `ls ~/.ssh/*.pub`
do
  KEY=`cat ${i}`
  docker exec -it js8 /bin/sh -c "echo ${KEY} >> /root/.ssh/authorized_keys" > /tmp/lastcommandoutput.txt 2>&1
  valid
done
if [ -e /proc/version ] && grep -q Microsoft /proc/version; then
  for i in `ls /mnt/c/Users/${WINDOWSUSERNAME}/.ssh/*.pub`
  do
    KEY=`cat ${i}`
    docker exec -it js8 /bin/sh -c "echo ${KEY} >> /root/.ssh/authorized_keys" > /tmp/lastcommandoutput.txt 2>&1
    valid
  done
fi
ssh-keygen -f ~/.ssh/known_hosts -R ${ZEROTIERIP} > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -it js8 /bin/sh -c 'echo "JSDEVELOPER WELCOME" > /etc/motd' > /tmp/lastcommandoutput.txt 2>&1
valid

echo "Downloading and building jumpscale 8.2"
docker exec -it js8 /bin/sh -c 'cd $TMPDIR;rm -f install.sh;export JSBRANCH="8.2.0";curl -k https://raw.githubusercontent.com/Jumpscale/jumpscale_core8/$JSBRANCH/install/install.sh?$RANDOM > install.sh; bash install.sh' > /tmp/lastcommandoutput.txt 2>&1
valid

#echo "Append the following lines to your .bashrc file to interact easily with jumpscale and ays"
echo "alias js='docker exec -it js8 js'" >> ~/.bashrc
echo "alias ays='docker exec -it js8 ays'" >> ~/.bashrc
echo "alias jsbash='docker exec -it js8 bash'" >> ~/.bashrc

echo
echo "Congratulations, your docker based jumpscale installation is ready!"
echo "Sandbox is present in the zerotier network ${ZEROTIERNWID} with ip: ${ZEROTIERIP}"
echo "run js, ays, or jsbash to work in your sandbox"
echo "ssh into your sandbox through ssh root@${ZEROTIERIP}"
. ~/.bashrc >> /dev/null 2>&1
