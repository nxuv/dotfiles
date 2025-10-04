#!/usr/bin/env -S just --justfile
# just reference  : https://just.systems/man/en/

# Example justfile with a bunch of tasks that I'd want to reuse

vpn:
    sudo iptables -F amnvpn.a.310.blockDNS

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
@help: list
    just --help

@default: help
    echo ""

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

