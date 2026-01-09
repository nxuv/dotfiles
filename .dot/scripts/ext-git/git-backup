#!/bin/fish

git add .
if count $argv > /dev/null
    git commit -m $argv
else
    git commit -m "Updated: $(date +'%Y-%m-%d %H:%M:%S')"
end
git push origin master


