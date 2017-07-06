#!/bin/bash
set -e

if [ -z ${JSENV+x} ]; then
    echo "[-] JSENV is not set, your environment is not loaded correctly."
    exit 1
fi

logfile="/tmp/install.log"
. $CODEDIR/github/jumpscale/developer/jsenv-functions.sh
catcherror

export bname=jumpscale/base3
export iname=js9
export port=2222

usage() {
   cat <<EOF
Usage: js9_start [-n $name] [-p $port]
   -n $name: name of container
   -p $port: port on which to install
   -b: build the docker, don't download from docker
   -r: reset docker, destroy first if already on host
   -c: continue using existing js9 docker
   -h: help

   example to do all: 'js9_start -n mymachine -p 2223' which will start a container with name myachine on port 2223 and download
   also works with specifying nothing

EOF
   exit 0
}
doreset(){
    dockerremove $iname
    dockerremove $bname
}


while getopts "n:p:rbhc" opt; do
   case $opt in
   n )  iname=$OPTARG ;;
   p )  port=$OPTARG ;;
   b )  build=1 ;;
   r )  reset=1 ;;
   c )  cont=1 ;;
   h )  usage ; exit 0 ;;
   \?)  usage ; exit 1 ;;
   esac
done
shift $(($OPTIND - 1))

showprompt=1
if [ -n "$reset" ]; then
  showprompt=0
  doreset
fi

if [ -n "$cont" ]; then
  showprompt=0
fi
dockerexists="$(docker ps -aq -f name=^/${iname}$)"
if [ "$showprompt" -eq 1 ] && [ ! -z "$dockerexists" ]; then
  while true; do
      read -p " [+] Do you want to reset the docker?" yn
      case $yn in
          [Yy]* ) doreset; break;;
          [Nn]* ) break;;
          * ) echo "Please answer with yes or no";;
      esac
  done

fi



if ! docker images | grep -q "$bname"; then
    if [ -n "${build}" ]; then
        dockerremoveimage $bname ;
        bash js_builder_base9.sh
    fi
fi

echo "[+] starting jumpscale9 development environment"

dockerrun $bname $iname $port js9_start

# echo "* update jumpscale code (js9_code update -a jumpscale -f )"
# ssh -A root@localhost -p ${port} 'export LC_ALL=C.UTF-8;export LANG=C.UTF-8;js9_code update -a jumpscale -f'
echo "* init js9 environment (js9_init)"
ssh -A root@localhost -p ${port} 'js9_init' #> ${logfile} 2>&1 || die "docker could not start, please check ${logfile}"


# configzerotiernetwork
#
# autostart


echo "[+] docker started"
echo "[+] please access over ssh using:"
echo "[+]    ssh -tA root@localhost -p ${port}"
