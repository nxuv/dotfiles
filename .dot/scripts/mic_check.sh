#!/bin/bash
[[ $(find /proc/asound -name status -exec grep -v closed {} + | grep RUNNING | wc -l) -ge 2 ]] && echo 'R' || echo '-'
