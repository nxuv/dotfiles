#!/bin/bash

[ -d "$HOME/.local/share/cron" ] || mkdir -p "$HOME/.local/share/cron"

curl ipinfo.io/ip --silent > "$HOME/.local/share/cron/external-ip.txt"

