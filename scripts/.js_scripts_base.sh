set +ex
clear

. ~/.jsenv.sh

function valid () {
  EXITCODE=$?
  if [ ${EXITCODE} -ne 0 ]; then
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
      exit ${EXITCODE}
  fi
}

trap valid ERR

function getcode {

    source ~/.jsenv.sh

    echo $CODEDIR/github/jumpscale/$1
    if [ ! -e $CODEDIR/github/jumpscale/$1 ]; then
        set +e
        git clone git@github.com:Jumpscale/$1.git
        if [ ! $? -eq 0 ]; then
            set -ex
            git clone https://github.com/Jumpscale/$1.git
        fi
        set +e
    else
        cd $CODEDIR/github/jumpscale/$1
        git pull
    fi
}

function initssh {
    if [ -z "$iname" ]; then
        echo "Please define name of docker instance by setting variable: iname"
        exit 1
    fi
    echo "* run ssh server."
    #killall -r .*ssh.*;
    #/usr/sbin/sshd
    docker exec -t $iname /bin/sh -c "rm -rf /root/.ssh;mkdir -p /root/.ssh;/usr/bin/ssh-keygen -A;/etc/init.d/ssh start" > /tmp/lastcommandoutput.txt 2>&1
    rm -f ~/.ssh/known_hosts
    echo "* copy my sshkey to container."
    if [ -e /proc/version ] && grep -q Microsoft /proc/version; then
        for i in `ls /mnt/c/Users/${WINDOWSUSERNAME}/.ssh/*.pub`
        do
          KEY=`cat ${i}`
          docker exec -t $iname /bin/sh -c "echo ${KEY} >> /root/.ssh/authorized_keys" > /tmp/lastcommandoutput.txt 2>&1
          valid
        done
    else
        KEY=`cat $HOMEDIR/.ssh/$SSHKEYNAME.pub`
        docker exec -t $iname /bin/sh -c "echo ${KEY} > /root/.ssh/authorized_keys"
        valid
    fi
}

function cleanup {
    if [ -z "$iname" ]; then
        echo "Please define name of docker instance by setting variable: iname"
        exit 1
    fi
    echo "* cleanup"
    docker exec -t $iname bash -c 'cleanup'
}

function commitdocker {
    if [ -z "$iname" ]; then
        echo "Please define name of docker instance by setting variable: iname"
        exit 1
    fi
    echo "* Creating docker image jumpscale/$iname"
    docker commit $iname jumpscale/$iname > /tmp/lastcommandoutput.txt 2>&1
    docker rm --force $iname > /tmp/lastcommandoutput.txt 2>&1
}

function autostart {
    if [ -z "$iname" ]; then
        echo "Please define name of docker instance by setting variable: iname"
        exit 1
    fi
    docker exec -t $iname /bin/sh -c "init"
}

function initjs {
    if [ -z "$iname" ]; then
        echo "Please define name of docker instance by setting variable: iname"
        exit 1
    fi
    echo "* init of jumpscale 9"
    docker exec -t $iname /bin/sh -c 'python3 -c "from JumpScale9 import j;j.do.initEnv()"' > /tmp/lastcommandoutput.txt 2>&1 #need to do it twice, ignore error first time
    docker exec -t $iname /bin/sh -c 'python3 -c "from JumpScale9 import j;j.tools.jsloader.generate()"' > /tmp/lastcommandoutput.txt 2>&1 #need to do it twice, ignore error first time
}

function copyfiles {
    echo "* sync files"
    docker exec -t $iname bash -c 'rsync -rav /opt/code/github/jumpscale/developer/scripts/files/ /' > /tmp/lastcommandoutput.txt 2>&1

}

# function addsshkeys {
#     if [ -e /proc/version ] && grep -q Microsoft /proc/version; then
#         for i in `ls /mnt/c/Users/${WINDOWSUSERNAME}/.ssh/*.pub`
#         do
#           KEY=`cat ${i}`
#           docker exec -t $1 /bin/sh -c "echo ${KEY} >> /root/.ssh/authorized_keys" > /tmp/lastcommandoutput.txt 2>&1
#           valid
#         done
#     else
#         KEY=`cat $HOMEDIR/.ssh/$SSHKEYNAME.pub`
#         docker exec -t $1 /bin/sh -c "echo ${KEY} | addsshkey"
#         valid
#     fi
# }

if [ -z "$SSHKEYNAME" ]; then
    echo "Need to set SSHKEYNAME (through export SSHKEYNAME='mykey')"
    exit 1
fi

if [ -z "$GIGDIR" ]; then
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


cat ~/.mascot.txt
echo
