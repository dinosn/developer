
# development environment for jumpscale 9

- please use this development environment to play & develop with jumpscale 9
- it uses docker and the goal is to get it to work on ubuntu, windows & osx

to see an install [screencast](http://showterm.io/5a87e36aee35b5b765b20#fast)

## init

```
curl https://raw.githubusercontent.com/Jumpscale/developer/master/jsinit.sh?$RANDOM > $TMPDIR/jsinstall.sh; sh $TMPDIR/jsinstall.sh
```



## Jumpscale 8.2 development env

```bash
curl -L https://tinyurl.com/js82installer | bash -s <Your zerotier network id>
```

to see interactive output do the following in separate console
```
tail -f /tmp/lastcommandoutput.txt
```

- [more detailed explanation](docs/installjs8_details.md)

## Jumpscale 9.0 development env

open a new console, this should make sure the env variables are set

```bash
jsinstall
```
this will configure docker & install jumpscale9

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
