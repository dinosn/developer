source /opt/jumpscale8/env.sh
js 'j.do.pullGitRepo("git@github.com:Jumpscale/builder.git")'
cd /opt/code/github/jumpscale/builder
js install/install.py
