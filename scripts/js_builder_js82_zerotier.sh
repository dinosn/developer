#!/bin/bash

function valid () {
  EXITCODE=$?
  if [ ${EXITCODE} -ne 0 ]; then
      cat /tmp/lastcommandoutput.txt
      if [ -z $1 ]; then
        echo "Error in last step"
      else
        echo $1
      fi
      exit ${EXITCODE}
  fi
}

if [ -z $1 ]; then
  echo "Usage: js82_builder_zerotier.sh <ZEROTIERNWID>"
  echo
  echo "  ZEROTIERNWID: The zerotier network in which the jumpscale should join."
  echo
  exit 1
fi
ZEROTIERNWID=$1

if (( `docker ps -a | grep js82 | wc -l` > 0 )); then
  echo "Cleaning up existing container instance"
  docker rm --force js82 > /tmp/lastcommandoutput.txt 2>&1
  valid
fi

if [ -e /proc/version ] && grep -q Microsoft /proc/version; then
  # Windows subsystem 4 linux
  WINDOWSUSERNAME=`ls -ail /mnt/c/Users/ | grep drwxrwxrwx | grep -v Public | grep -v Default | grep -v '\.\.'`
  WINDOWSUSERNAME=${WINDOWSUSERNAME##* }
  GIGHOME=${GIGPATH:-/mnt/c/Users/${WINDOWSUSERNAME}/gig}
else
  # Native Linux or MacOSX
  GIGHOME=${GIGPATH:-~/gig}
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

if ! docker images | grep -q "jumpscale/ubuntu-zerotier"; then
  echo "Starting docker container"
  docker run --name ubuntu-zerotier -h ubuntu-zerotier -d --device=/dev/net/tun --cap-add=NET_ADMIN --cap-add=SYS_ADMIN -v ${GIGHOME}/zerotier-one/:/var/lib/zerotier-one/ -v ${GIGHOME}/code/:/opt/code/ -v ${GIGHOME}/data/:/optvar/data ubuntu:16.04 sleep 365d > /tmp/lastcommandoutput.txt 2>&1
  valid

  echo "Correcting the locales env"
  docker exec -t ubuntu-zerotier bash -c 'echo -e "export LC_ALL=C.UTF-8\nexport LANG=C.UTF-8" >> /root/.bashrc' > /tmp/lastcommandoutput.txt 2>&1
  valid
  docker exec -t ubuntu-zerotier bash -c 'echo -e "export LC_ALL=C.UTF-8\nexport LANG=C.UTF-8" >> /root/.bash_profile' > /tmp/lastcommandoutput.txt 2>&1
  valid
  docker exec -t ubuntu-zerotier bash -c 'echo -e "export LC_ALL=C.UTF-8\nexport LANG=C.UTF-8" >> /root/.profile' > /tmp/lastcommandoutput.txt 2>&1
  valid

  echo "Installing zerotier"
  docker exec -t ubuntu-zerotier bash -c "cd && apt-get update && apt-get install -y curl openssh-server git make g++ vim mc localehelper && mkdir /var/run/sshd && git clone https://github.com/zerotier/ZeroTierOne.git && cd ZeroTierOne/ && make && make install" > /tmp/lastcommandoutput.txt 2>&1
  valid

  echo "Creating docker init"
  docker exec -t ubuntu-zerotier bash -c 'echo -e "tmux set-environment -g LC_ALL C.UTF-8\ntmux set-environment -g LANG C.UTF-8\nzerotier-one -d\n/usr/sbin/sshd\nsleep 1\nzerotier-cli join \${ZEROTIERNWID}\n" > /root/init-include.sh' > /tmp/lastcommandoutput.txt 2>&1
  valid
  docker exec -t ubuntu-zerotier bash -c 'echo -e "#!/bin/bash\nZEROTIERNWID=\$1\nsource /root/init-include.sh\nsleep 36500d\n" > /root/init.sh' > /tmp/lastcommandoutput.txt 2>&1
  valid
  docker exec -t ubuntu-zerotier chmod +x /root/init.sh > /tmp/lastcommandoutput.txt 2>&1
  valid

  echo "Creating docker image jumpscale/ubuntu-zerotier"
  docker commit ubuntu-zerotier jumpscale/ubuntu-zerotier > /tmp/lastcommandoutput.txt 2>&1
  valid
  docker rm --force ubuntu-zerotier > /tmp/lastcommandoutput.txt 2>&1
  valid
fi

echo "Spawning js82 docker container"
docker run --name js82 -h js82 -d --device=/dev/net/tun --cap-add=NET_ADMIN --cap-add=SYS_ADMIN -v ${GIGHOME}/zerotier-one/:/var/lib/zerotier-one/ -v ${GIGHOME}/code/:/opt/code/ -v ${GIGHOME}/data/:/optvar/data jumpscale/ubuntu-zerotier /root/init.sh ${ZEROTIERNWID} > /tmp/lastcommandoutput.txt 2>&1
valid

echo "Waiting for ip in zerotier network (do not forget to allow the container in your network, and make sure auto assign ip is enabled) ..."
while :
do
  sleep 1
  ZEROTIERIP=`docker exec -t js82 bash -c "ip -4 addr show zt0 | grep -oP 'inet\s\d+(\.\d+){3}' | sed 's/inet //' | tr -d '\n\r'"`
  if [ "${ZEROTIERIP}" ]; then
    echo "Container zerotier ip = ${ZEROTIERIP}"
    break
  fi
done

echo "Configuring ssh access"
docker exec -t js82 bash -c "mkdir /root/.ssh && chmod 700 /root/.ssh"> /tmp/lastcommandoutput.txt 2>&1
valid
for i in `ls ~/.ssh/*.pub`
do
  KEY=`cat ${i}`
  docker exec -t js82 bash -c "echo ${KEY} >> /root/.ssh/authorized_keys" > /tmp/lastcommandoutput.txt 2>&1
  valid
done
if [ -e /proc/version ] && grep -q Microsoft /proc/version; then
  for i in `ls /mnt/c/Users/${WINDOWSUSERNAME}/.ssh/*.pub`
  do
    KEY=`cat ${i}`
    docker exec -t js82 bash -c "echo ${KEY} >> /root/.ssh/authorized_keys" > /tmp/lastcommandoutput.txt 2>&1
    valid
  done
fi
for user in `curl -s https://raw.githubusercontent.com/Jumpscale/developer/master/scripts/devs`;
do
  docker exec -t js82 bash -c "curl -s https://github.com/${user}.keys >> /root/.ssh/authorized_keys" > /tmp/lastcommandoutput.txt 2>&1
done
docker exec -t js82 bash -c "chmod 600 /root/.ssh/authorized_keys"> /tmp/lastcommandoutput.txt 2>&1
valid
ssh-keygen -R ${ZEROTIERIP} -f ~/.ssh/known_hosts > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js82 bash -c 'curl https://raw.githubusercontent.com/Jumpscale/developer/master/mascot > /etc/motd' > /tmp/lastcommandoutput.txt 2>&1
valid

echo "Downloading and building jumpscale 8.2"
docker exec -t js82 bash -c 'apt-get update'  > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js82 bash -c 'cd $TMPDIR && rm -f install.sh && export JSBRANCH="8.2.0" && curl -k https://raw.githubusercontent.com/Jumpscale/jumpscale_core8/$JSBRANCH/install/install.sh?$RANDOM > install.sh && bash install.sh' > /tmp/lastcommandoutput.txt 2>&1
valid

if ! grep -q "alias js82='docker exec -it js82 js'" ~/.bashrc; then
  echo "alias js82='docker exec -it js82 js'" >> ~/.bashrc
fi
if ! grep -q "alias ays82='docker exec -it js82 ays'" ~/.bashrc; then
  echo "alias ays82='docker exec -it js82 ays'" >> ~/.bashrc
fi
if ! grep -q "alias js82bash='docker exec -it js82 bash'" ~/.bashrc; then
  echo "alias js82bash='docker exec -it js82 bash'" >> ~/.bashrc
fi

echo "Creating docker image jumpscale/js82"
docker commit js82 jumpscale/js82 > /tmp/lastcommandoutput.txt 2>&1
valid

echo
echo "Congratulations, your docker based jumpscale installation is ready!"
echo "Sandbox is present in the zerotier network ${ZEROTIERNWID} with ip: ${ZEROTIERIP}"
echo "Run js82, ays82, or js82bash in a new shell to work in your sandbox"
echo "ssh into your sandbox through ssh root@${ZEROTIERIP}"
echo
echo "Recreate a new jumscale docker without rebuilding as follows:"
echo "  docker rm --force js82; docker run --name js82 -h js82 -d --device=/dev/net/tun --cap-add=NET_ADMIN --cap-add=SYS_ADMIN -v ${GIGHOME}/zerotier-one/:/var/lib/zerotier-one/ -v ${GIGHOME}/code/:/opt/code/ -v ${GIGHOME}/data/:/optvar/data jumpscale/js82 /root/init.sh ${ZEROTIERNWID}"
