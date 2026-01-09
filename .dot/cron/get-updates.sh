#!/bin/bash

[ -d "$HOME/.local/share/cron" ] || mkdir -p "$HOME/.local/share/cron"

xbps-install -un > "$HOME/.local/share/cron/xbps-update-list.txt"

