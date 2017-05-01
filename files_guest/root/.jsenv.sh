
clear

export CODEDIR=/opt/code
export GIGDIR=/root/gig
mkdir -p $GIGDIR

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export TERM=screen-256color
export PS1="gig:\h:\w$\[$(tput sgr0)\]"
