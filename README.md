# builder
builder for lots of sandboxes, so it can be used in e.g. g8os


### to login into the docker

```
ssh root@localhost -p 2222
```

## install

```
#MAKE SURE YOU SELECT YOUR KEY NAME
export SSHKEYNAME='ovh_install'

cd $TMPDIR;rm -f jsdeveloper.sh
curl -k https://raw.githubusercontent.com/Jumpscale/developer/master/install.sh?$RANDOM > jsdeveloper.sh
bash jsdeveloper.sh
```

## see other scriots in /scripts dir

- prepare.sh : execute this to make sure that your local environment is up to date
- js_builder.sh : build jumpscale 8 on branch 8.2.0 inside the docker with name js

# cleanup
```
#remove all old dockers
docker rm $(docker ps -a -q)
```
