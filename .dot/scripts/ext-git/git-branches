#!/bin/fish

git branch 2> /dev/null | fzf | sed "s/.* //" | awk "{print $argv[1]}" | xargs git checkout

