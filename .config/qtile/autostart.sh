#!/bin/bash

# (cd "$HOME/.config/polybar/" && "$HOME/.dotfiles/scripts/rerun" "$HOME/.config/polybar/launch.sh") &

# rem-accel () {
#     xinput set-prop "$1" "libinput Accel Speed" -0.4
#     xinput set-prop "$1" "libinput Accel Profile Enabled" 1 0 0
# }

# rem-accel "pointer:Logitech ERGO M575" || echo "Missing ERGO M575"
# rem-accel "pointer:Logitech G304" || echo "Missing G304"

# rem-accel () {
#     xinput set-prop "$1" "libinput Accel Speed" -0.4
#     xinput set-prop "$1" "libinput Accel Profile Enabled" 1 0 0
# }

# rem-accel "pointer:Logitech ERGO M575" || echo "Missing ERGO M575"
# rem-accel "pointer:Logitech G304" || echo "Missing G304"

#                 1920/2 1080/2
xdotool mousemove 960    540
xdotool click 1

sleep 1

xinput --map-to-output 'Melfas LGDisplay Incell Touch' DisplayPort-0

# - ---------------------------------------------------------------------------- -
# -                    /etc/X11/xorg.conf.d/40-libinput.conf                     -
# - ---------------------------------------------------------------------------- -
# Section "InputClass"
#         Identifier "Logitech ERGO M575"
#         MatchIsPointer "on"
#         Driver "libinput"
# 	Option "AccelProfile" "adaptive" # "flat"
# 	Option "AccelSpeed" "-0.4"
# EndSection
# - ---------------------------------------------------------------------------- -

