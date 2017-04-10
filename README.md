# builder
builder for lots of sandboxes, so it can be used in e.g. g8os


## get started with base image
```
#MAKE SURE YOU SELECT YOUR KEY NAME
export SSHKEYNAME='ovh_install'
#remote older ssh sessions
rm -rf /Users/despiegk/.ssh/known_hosts
docker rm --force js8
docker run --name js8 -h js8 -d -p 2222:22 -v ~/.ssh/$SSHKEYNAME.pub:/root/.ssh/authorized_keys -v ~/data/:/data/ macropin/sshd
ssh root@localhost -p 2222 'apk update;apk add curl'
```

### to login into the docker

```
ssh root@localhost -p 2222
```

## see scripts dir

```
#MAKE SURE YOU SELECT YOUR KEY NAME
export SSHKEYNAME='ovh_install'

mkdir -p /opt/code/github/jumpscale
cd /opt/code/github/jumpscale
git clone git@github.com:Jumpscale/builder.git

cd builder/scripts

sh prepare.sh #only need to do this once
sh js_builder.sh

```

different scripts

- prepare.sh : execute this to make sure that your local environment is up to date
- js_builder.sh : build jumpscale 8 on branch 8.2.0 inside the docker with name js

# cleanup
```
#remove all old dockers
docker rm $(docker ps -a -q)
```
