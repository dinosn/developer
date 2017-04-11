set -ex

#BE VERY CAREFUL THIS REMOVES YOUR BREW & ALL YOUR EXISTING CODE !!!

if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform
    # echo 'install brew'
    export LANG=C; export LC_ALL=C
    osx_install


echo -n "Do you want to uninstall virtualbox (y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ;then
    curl -s https://gist.githubusercontent.com/lox/52f27919816a7eadb6d3/raw/uninstall_virtualbox.sh | bash
fi

echo -n "Do you want to uninstall virtualbox (y/n)? "
read answer
if echo "$answer" | grep -iq "^y" ;then
    curl -s https://gist.githubusercontent.com/lox/52f27919816a7eadb6d3/raw/uninstall_virtualbox.sh | bash
fi

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
rm -rf ~/.homebrew
rm -rf ~/.rvm
rm -rf /opt
rm -rf /optvar
rm -rf ~/data
rm -rf ~/code
rm -rf ~/opta
rm -rf ~/optvar
rm -rf ~/tmp
rm -rf ~/.npm
rm -rf ~/.ipython
rm -rf ~/.dlv
rm -rf ~/.cups
rm -rf /usr/local

