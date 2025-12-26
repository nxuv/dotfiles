#!/bin/sh

pipewire &

numlockx &
xsettingsd &
dunst &

gnome-keyring-daemon --start &

pasystray &
# powerkit &
# blueman-applet &
# blueman-tray &

# lxqt-policykit-agent &

