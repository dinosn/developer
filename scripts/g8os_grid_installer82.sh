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

if [ -z $1 ] || [ -z $2 ] || [ -s $3 ]; then
  echo "Usage: ays_grid_installer82.sh <BRANCH> <ZEROTIERNWID> <ZEROTIERTOKEN>"
  echo
  echo "  BRANCH: Grid development branch."
  echo "  ZEROTIERNWID: Zerotier network id."
  echo "  ZEROTIERTOKEN: Zerotier api token."
  echo
  exit 1
fi
BRANCH=$1
ZEROTIERNWID=$2
ZEROTIERTOKEN=$3

if (( `docker ps -a | grep js82 | wc -l` < 1 )); then
  echo "js82 docker container is not running"
  exit 1
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

echo "Installing grid dependencies"
docker exec -t js82 bash -c "pip3 install git+https://github.com/g8os/core0.git@${BRANCH}#subdirectory=pyclient" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js82 bash -c "pip3 install zerotier" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js82 jspython -c "from js9 import j; j.tools.cuisine.local.development.golang.install()" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js82 mkdir -p /usr/local/go > /tmp/lastcommandoutput.txt 2>&1
valid

echo "Updating AYS grid server"
pushd ${GIGHOME}/code/github/ > /tmp/lastcommandoutput.txt 2>&1
valid
mkdir -p g8os > /tmp/lastcommandoutput.txt 2>&1
valid
pushd g8os > /tmp/lastcommandoutput.txt 2>&1
valid
if [ ! -d "grid" ]; then
  git clone git@github.com:g8os/grid.git > /tmp/lastcommandoutput.txt 2>&1
  valid
fi
pushd grid > /tmp/lastcommandoutput.txt 2>&1
valid
git pull
valid
git checkout ${BRANCH} > /tmp/lastcommandoutput.txt 2>&1
valid
if ! docker exec -t js82 cat /root/init-include.sh | grep -q "ays start"; then
  docker exec -t js82 bash -c "echo ays start >> /root/init-include.sh" > /tmp/lastcommandoutput.txt 2>&1
  valid
fi

echo "Building grid api server"
docker exec -t js82 bash -c "mkdir -p /opt/go/proj/src/github.com" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js82 bash -c "if [ ! -d /opt/go/proj/src/github.com/g8os ]; then ln -sf /opt/code/github/g8os /opt/go/proj/src/github.com/g8os; fi" > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js82 bash -c "cd /opt/go/proj/src/github.com/g8os/grid/api; GOPATH=/opt/go/proj GOROOT=/opt/go/root/ /opt/go/root/bin/go get -d ./...; GOPATH=/opt/go/proj GOROOT=/opt/go/root/ /opt/go/root/bin/go build -o /root/gridapiserver" > /tmp/lastcommandoutput.txt 2>&1
valid

echo "Starting grid api server"
ZEROTIERIP=`docker exec -t js82 bash -c "ip -4 addr show zt0 | grep -oP 'inet\s\d+(\.\d+){3}' | sed 's/inet //' | tr -d '\n\r'"`
if ! docker exec -t js82 cat /root/init-include.sh | grep -q "/root/gridapiserver"; then
  docker exec -t js82 bash -c 'echo "nohup /root/gridapiserver --bind '"${ZEROTIERIP}"':8080 --ays-url http://127.0.0.1:5000 --ays-repo my-little-grid-server > /var/log/gridapiserver.log 2>&1 &"  >> /root/init-include.sh' > /tmp/lastcommandoutput.txt 2>&1
  valid
fi
docker stop js82 > /tmp/lastcommandoutput.txt 2>&1
valid
docker start js82  > /tmp/lastcommandoutput.txt 2>&1
valid

echo "Waiting for api server to be ready"
docker exec -t js82 bash -c "while true; do if [ -d /optvar/cockpit_repos/my-little-grid-server ]; then break; fi; sleep 1; done"
echo "Deploying bootstrap service"
docker exec -t js82 bash -c 'echo -e "bootstrap.g8os__grid1:\n  zerotierNetID: '"${ZEROTIERNWID}"'\n  zerotierToken: '"${ZEROTIERTOKEN}"'\n\nactions:\n  - action: install\n" > /optvar/cockpit_repos/my-little-grid-server/blueprints/bootstrap.bp'
docker exec -t js82 bash -c 'cd /optvar/cockpit_repos/my-little-grid-server; ays blueprint' > /tmp/lastcommandoutput.txt 2>&1
valid
docker exec -t js82 bash -c 'cd /optvar/cockpit_repos/my-little-grid-server; ays run create --follow -y' > /tmp/lastcommandoutput.txt 2>&1
valid

echo
echo "Your ays server is ready to bootstrap nodes into your zerotier network."
echo "Download your ipxe boot iso image https://bootstrap.gig.tech/iso/${BRANCH}/${ZEROTIERNWID} and boot up your nodes!"
echo "Enjoy your grid api server: http://${ZEROTIERIP}:8080/"
