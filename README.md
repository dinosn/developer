# development environment for jumpscale 8

- please use this development environment to play & develop with jumpscale 8
- it uses docker and the goal is to get it to work on ubuntu, windows & osx

## init

```
curl https://raw.githubusercontent.com/Jumpscale/developer/master/jsinit.sh?$RANDOM > $TMPDIR/jsinstall.sh; sh $TMPDIR/jsinstall.sh
```

## install development env

open a new console, this should make sure the env variables are set
or do: source ~/jsenv.sh ;jsinstall
```
jsinstall
```

this will configure docker

## to login into the development machine

```
ssh root@localhost -p 2222
```

## recommended tools

- all jumpscale code is checked out under /opt/code
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
