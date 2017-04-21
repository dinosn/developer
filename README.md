
# development environment for jumpscale 9

- please use this development environment to play & develop with jumpscale 9
- it uses docker and the goal is to get it to work on ubuntu, windows & osx

## init

```
curl https://raw.githubusercontent.com/Jumpscale/developer/master/jsinit.sh?$RANDOM > $TMPDIR/jsinstall.sh; sh $TMPDIR/jsinstall.sh
```

## Jumpscale 8.2 development env

- one liner docker/zerotier installer

Just execute the following line with your zerotier id:
```bash
curl -L https://tinyurl.com/js82installer | bash -s <Your zerotier network id>
```

to see interactive output do the following in separate console
```
tail -f /tmp/lastcommandoutput.txt
```

It will
- create
  - ~/gig/code
  - ~/gig/data
  - ~/gig/zerotier
- spawn a docker
- join the docker into your zerotier network
- copy your ssh public keys into the dockers /root/.ssh/authorized_keys file
- download and install jumpscale
- create aliases in your .bashrc file
  - js82: shortcut to run jumpscale shell inside the docker
  - ays82: shortcut to run ays inside the docker
  - js82bash: shortcut to run a bash inside your docker


Example output:
```
curl -L https://tinyurl.com/js82installer | bash -s 876567546548907697
Cleaning up existing container instance
Starting docker container
Joining zerotier network
Waiting for ip in zerotier network (do not forget to allow the container in your network, and make sure auto assign ip is enabled) ...
Container zerotier ip = 192.168.193.81
Installing jumpscale dependencies
Configuring ssh access
Downloading and building jumpscale 8.2

Congratulations, your docker based jumpscale installation is ready!
Sandbox is present in the zerotier network 93afae5963151669 with ip: 192.168.193.81
run js82, ays82, or js82bash in a new shell to work in your sandbox
ssh into your sandbox through ssh root@192.168.193.81
```



## install development env for jumpscale 9

open a new console, this should make sure the env variables are set
or do: source ~/jsenv.sh ;jsinstall
```
jsinstall
```

this will configure docker & install basic of jumpscale9

to see interactive output do the following in separate console
```
tail -f /tmp/lastcommandoutput.txt
```

## to login into the development machine

```
ssh root@localhost -p 2222
#or
ssh root@zerotierNetworkId
```

## to start with shellcmds

```bash
js
```

 - this will change, is just to get started

## recommended tools

- all jumpscale code is checked out under /opt/code in development env or in ~/code/...
- use a ide like atom for development on this code, sourcetree is a good tool for git manipulation
- over ssh you can play with the code in the docker
- to push changes to a remote host (remote development) use j.tools.develop...


## see other scripts in /scripts dir

- prepare.sh : execute this to make sure that your local environment is up to date
- js_builder.sh : build jumpscale 8 on branch 8.2.0 inside the docker with name js

## cleanup
```
#remove all old dockers
docker rm $(docker ps -a -q)
```

### to remove homebrew and /opt on mac osx

```
curl https://raw.githubusercontent.com/Jumpscale/developer/master/scripts/osx_reset_all.sh?$RANDOM > $TMPDIR/resetall.sh;bash $TMPDIR/resetall.sh
```
