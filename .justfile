#!/usr/bin/env -S just --justfile
# just reference  : https://just.systems/man/en/

# Example justfile with a bunch of tasks that I'd want to reuse

# sudo xbps-install $(xbps-query -Rs --regex --property pkgver '^SDL[23]' | awk '{print $2}')

[private]
@default: list

# Remove amnezia dns blocking table
vpn:
    sudo iptables -F amnvpn.a.310.blockDNS

# Check if google is pingable
ping:
    ping google.com

# Mounts drive in userspace
usermount drive:
    #!/bin/sh -e
    if [ -z "{{drive}}" ]; then
        echo "Missing drive path"
        exit 1
    fi
    udisksctl mount -b "{{drive}}"

# List available recipes
@list:
    echo ""
    echo "Available Recipes at $PWD are:"
    echo ""
    just -l --list-prefix 'just ' --list-heading ''
    echo ""
    echo "just <module_name> to see sub-tasks"
    echo ""

# Show help/usage for "just" command
@help:
    just --help --color=never


[private]
build file: (track file) && (hash file)
    echo "Compiling file"

# Don't forget to add '.hashes' to gitignore
[private]
[no-exit-message]
track file:
    #!/usr/bin/env bash
    [ ! -f .hashes ] && touch .hashes
    [[ "$(md5sum {{file}} | head -c 32)" == "$(grep " {{file}}$" .hashes | head -c 32)" ]] && exit 1 || exit 0

[private]
hash file: (track file)
    #!/usr/bin/env bash
    echo "$(grep -v " {{file}}$" .hashes)" > .hashes && md5sum {{file}} >> .hashes

