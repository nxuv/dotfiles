#!/bin/bash

copyEtc() {
    echo "Copying /etc/$1"
    sudo cp -rT $HOME/.dot/root/etc/$1 /etc/$1
}

copyEtcFile() {
    echo "Copying /etc/$1"
    sudo cp $HOME/.dot/root/etc/$1 /etc/$1
}

copyEtc greetd
copyEtc zsh

copyEtcFile pacman.conf

echo "Copying X config to $HOME"

cp $HOME/.dot/root/xconfig/.xprofile $HOME/.xprofile
cp $HOME/.dot/root/xconfig/.xstartwm $HOME/.xstartwm

echo "Successfully finished"

