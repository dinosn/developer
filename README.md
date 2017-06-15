# Development environment

Use this development environment to play & develop with JumpScale.
It uses Docker and the goal is to get it to work on Ubuntu, Windows & Mac OS X.

## JumpScale 9

### Install a specific branch (optional)
By default, master branch is installed, if you want to install from a specific branch, first set the `GIGBRANCH` and/or `GIGDEVELOPERBRANCH` environment variable:

```bash
export GIGBRANCH=master
export GIGDEVELOPERBRANCH=master
```

- GIGDEVELOPERBRANCH: the branch for the deverloper repo in jumpscale
- GIGBRANCH: the branch which will be used for all other repo's on jumpscale, if that branch does not exist then it will fallback to master

- if the code repository already exists then it will just do a pull of the branch on disk (without losing local change, will crash if change).
    
### Protect host bash_profile (optional)

- THIS IS NOT RECOMMENDED TO DO, only use this when you don't want any change in your system
- If you don't want the JumpScale install script change your `bash_profile`, set the `GIGSAFE` environment variable:

```bash
export GIGSAFE=1
```

### Choose your JumpScale base directory (optional)
By default all the code will be installed in `~/gig`, if you want to use another location, export the `GIGDIR` environment variable:

```bash
export GIGDIR=/home/user/development/otherdir/gig
```

### Initialize the host
First execute `jsinit.sh` in order to prepare the installation:

```bash
export GIGBRANCH="master"
curl https://raw.githubusercontent.com/Jumpscale/developer/${GIGBRANCH}/jsinit.sh?$RANDOM > /tmp/jsinit.sh; bash /tmp/jsinit.sh
```

### Build the Docker image

Before executing any `js9_*` command please use `source ~/.jsenv.sh` first.

Then in order to build the Docker image execute `js9_build`:

```bash
#-l installs extra libs, AYS and prefab
#-p installs portal
js9_build #without options will install the basic docker with basic jumpscale9 support
```

To see all options do `js9_build -h`.

To see detailed output while the script is running do the following in a separate console:

```bash
#step 1 (when base docker is building)
docker exec -t js9_base0 tail -f /tmp/install.log
#step 2 (further installation)
tail -f /tmp/install.log
```

As a result a new Docker image with the name `js9_base` will be build and a container with the same name will be started. The script will check whether your private SSH key is loaded. If that is the case it will add your public key to `authorized_keys`. If no key is loaded, it will ask for the name of your private key.

to make sure you rebuild the base docker you need to find & remove docker base0
```bash
docker rmi jumpscale/docker0 -f
```


to troubleshoot and you want to go inside the docker
```
docker exec -ti js9 /bin/bash
```

### Start the Docker container

As a result of the previous step a container image with the name `js9_base` got created.

With `js9_start` the running container will be stopped and removed, and a new one will be started:

```shell
js9_start
```

`js9_start` allows you to control the name of the container with the `-n` option (default name is `js9`), and the SSH port with the `-p` option (default port is 2222).

`js9_start` will start a new container based on the local image. If it doesn't find any local image, it downloads one from Docker Hub. With the `-b` option you instruct `js9_start` to first build a new image, which then always includes AYS, prefab and some extra libraries, but excluding the portal framework. If you want to rebuild the image that includes the portal framework, you need to you `js9_build` with the `-p` option.


### SSH into the container

```shell
ssh root@localhost -p 2222
```


## Start with the JumpScale interactive shell

```bash
js9
```

## Recommended tools

- All JumpScale code is checked out under `/opt/code` in the development environment or in `~/gig/code/...`
- Use an IDE like Atom for development, SourceTree is a good tool for Git manipulation
- Over SSH you can play with the code in the Docker container
- To push changes to a remote host (remote development) use `j.tools.develop...`


## Cleanup

```
#remove all old dockers
docker rm $(docker ps -a -q)
```

## Removing Homebrew and /opt on Mac OS X

```
curl https://raw.githubusercontent.com/Jumpscale/developer/master/scripts/osx_reset_all.sh?$RANDOM > $TMPDIR/resetall.sh;bash $TMPDIR/resetall.sh
```
