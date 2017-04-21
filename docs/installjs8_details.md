## one liner docker/zerotier installer

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
