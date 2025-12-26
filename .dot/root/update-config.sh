#!/bin/bash
copyEtc() {
    echo "Copying /etc/$1"
    rm -rf ~/.dot/root/etc/$1
    cp -rT /etc/$1 ~/.dot/root/etc/$1
}

copyEtcFile() {
    echo "Copying /etc/$1"
    rm -f ~/.dot/root/etc/$1
    cp /etc/$1 ~/.dot/root/etc/$1
}

copyEtc greetd
copyEtc zsh

copyEtcFile pacman.conf

echo "Copying X config from $HOME"

rm -rf ~/.dot/root/xconfig
mkdir ~/.dot/root/xconfig
cp ~/.xprofile ~/.dot/root/xconfig/.xprofile
cp ~/.xexec ~/.dot/root/xconfig/.xexec

echo "Successfully finished"

