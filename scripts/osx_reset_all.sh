set -e

#BE VERY CAREFUL THIS REMOVES YOUR BREW & ALL YOUR EXISTING CODE !!!

if [ "$(uname)" == "Darwin" ]; then
    export LANG=C; export LC_ALL=C

    echo -n "Do you want to uninstall virtualbox (y/n)? "
    read answer
    if echo "$answer" | grep -iq "^y"; then
        curl -s https://gist.githubusercontent.com/lox/52f27919816a7eadb6d3/raw/uninstall_virtualbox.sh | bash
    fi

    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
    sudo rm -rf ~/.homebrew
    sudo rm -rf ~/.rvm
    sudo rm -rf /opt
    sudo rm -rf /optvar
    sudo rm -rf ~/data
    sudo rm -rf ~/code
    sudo rm -rf ~/opta
    sudo rm -rf ~/optvar
    sudo rm -rf ~/tmp
    sudo rm -rf ~/.npm
    sudo rm -rf ~/.ipython
    sudo rm -rf ~/.dlv
    sudo rm -rf ~/.cups
    sudo rm -rf /usr/local


fi
