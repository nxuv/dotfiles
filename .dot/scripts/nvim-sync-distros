#!/bin/bash

# Requirements:
#     rcs   - merge
#     ranger - for managing merged dir
#     nvim  - obviously needed

# TODO: sync after/ instead

FILE_DIFFS=""
FILE_ONLY=""
FILE_REMOVE=""

DIR_SYNCS=""
FILE_SYNCS=""

function confirm() {
    read -r -p "$@" YN </dev/tty
    YN="$(echo "$YN" | tr -d "\n")"
    [[ "$YN" == "" ]] && return 1
    [[ "$YN" =~ ^[^Yy].*$ ]] && return 1
    return 0
}

function confirm_y() {
    read -r -p "$@" YN </dev/tty
    YN="$(echo "$YN" | tr -d "\n")"
    [[ "$YN" == "" ]] && return 0
    [[ "$YN" =~ ^[^Yy].*$ ]] && return 1
    return 0
}

function wait_for_input() {
    read -r -p "Press any key to continue" __none </dev/tty
}

function df_merge() {
    merge -A -q -p "$2" "$1" "$2" | nvim +"file $2"
}

function df_file() {
    _diff_res="$(diff -q "$1" "$2")"
    FILE_DIFFS="$FILE_DIFFS\n$_diff_res"
}

function df_dirs() {
    _diff_res="$(diff -q -r "$1" "$2" | sed '/^\s*Only in.*$/d')"
    FILE_DIFFS="$FILE_DIFFS\n$_diff_res"
    _diff_res="$(diff -q -r "$1" "$2" | sed '/^\s*Only in.*$/!d')"
    FILE_ONLY="$FILE_ONLY\n$_diff_res"
}

function __sync_dir() {
    # already includes leading / since full path
    tmp_dir="/tmp/vimsync$1"
    [ -d "$tmp_dir" ] && rm -rf "$tmp_dir"
    mkdir -pv "$tmp_dir" > /dev/null

    cp -rf "$2"/** "$tmp_dir"
    cp -rf "$1"/** "$tmp_dir"

    # echo "$"
    echo "$(echo "Merged directory \"$1\" with \"$2\"" | sed "s+$MON_NV+monolith.nvim+;s+$DES_NV+despair.nvim+")"
    # echo ""
}

function __sync_dirs_all() {
    echo -e "$DIR_SYNCS" | while read line; do
        DF_A="$(echo -e "$line" | cut -d "|" -f 1)"
        DF_B="$(echo -e "$line" | cut -d "|" -f 2)"
        __sync_dir "$DF_A" "$DF_B"
    done

    echo ""

    FILE_ONLY_COUNT=$(echo -e "$FILE_ONLY_LIST" | wc -l)
    [[ ! -n "$FILE_ONLY_LIST" ]] && FILE_ONLY_COUNT=0 
    [[ FILE_ONLY_COUNT -eq 0 ]] && return 0

    echo "Found $FILE_ONLY_COUNT unique files:"
    echo -e "$FILE_ONLY_LIST" | while read line; do
        echo "    $line"
    done
    echo ""
    echo "Do you want to manually select which to keep or keep all"
    if confirm_y "Manually select which to keep? [Y/n]: "; then
        shopt -s lastpipe
        echo -e "$FILE_ONLY_LIST" | while read line; do
            confirm_y "Keep \"$line\"? [Y/n]: " || FILE_REMOVE="$FILE_REMOVE\n$line"
        done
    fi

    FILE_REMOVE="$(echo -e "$FILE_REMOVE" | sed "/^\s*$/d")"
    tmp_dir="/tmp/vimsync$MON_NV"
    echo -e "$FILE_REMOVE" | while read line; do
        [[ "$line" != "$tmp_dir" ]] && rm "$tmp_dir/$line"
    done
}

function syncdir() {
    DIR_SYNCS="$DIR_SYNCS\n$1|$2"
    df_dirs $1 $2
}

function syncfile() {
    FILE_SYNCS="$FILE_SYNCS\n$1|$2"
    df_file $1 $2
}

function cpdir() {
    rm -rf "$2/$(basename $1)"
    cp -r $1 $2
}

function cpfile() {
    _fname="$2/$(basename $1)"
    rm "$2/$(basename $1)"
    cp $1 $2
}

MON_NV="$XDG_CONFIG_HOME/monolith.nvim"
DES_NV="$XDG_CONFIG_HOME/despair.nvim"

# Dirs rio
syncdir "$MON_NV/colors" "$DES_NV/colors"
syncdir "$MON_NV/after" "$DES_NV/after"
syncdir "$MON_NV/plugin/sil" "$DES_NV/plugin/sil"
syncdir "$MON_NV/lua/lib" "$DES_NV/lua/lib"
syncdir "$MON_NV/lua/opt" "$DES_NV/lua/opt"
# Files
# syncfile "$MON_NV/lua/config/theme.lua" "$DES_NV/lua/theme.lua"
# syncfile "$MON_NV/lua/config/filetypes.lua" "$DES_NV/lua/filetypes.lua"
# syncfile "$MON_NV/lua/config/options.lua" "$DES_NV/lua/options.lua"
# syncfile "$MON_NV/lua/config/commands.lua" "$DES_NV/lua/commands.lua"
# syncfile "$MON_NV/lua/config/keymap.lua" "$DES_NV/lua/keymap.lua"
# syncfile "$MON_NV/lua/config/keyfunc.lua" "$DES_NV/lua/keyfunc.lua"

# syncfile "$MON_NV/lua/setglobals.lua" "$DES_NV/lua/setglobals.lua"
# syncfile "$MON_NV/lua/colorscheme.lua" "$DES_NV/lua/colorscheme.lua"
# syncfile "$MON_NV/lua/module.lua" "$DES_NV/lua/module.lua"
# syncfile "$MON_NV/lua/map.lua" "$DES_NV/lua/map.lua"

FILE_ONLY_LIST="$(echo -e "$FILE_ONLY" | sed -r "s+$MON_NV/++;s+$DES_NV/++;s+Only in (.*?): +\1/+;/^\s*$/d")"

FILE_DIFFS="$(echo -e "$FILE_DIFFS" | sed '/^\s*$/d')"

FILE_DIFF_NUM=$(echo -e "$FILE_DIFFS" | wc -l)
[ ! -n "$FILE_DIFFS" ] && FILE_DIFF_NUM=0

FILE_DIFFS_PRETTY="$(echo -e "$FILE_DIFFS" | sed "s+$MON_NV+monolith.nvim+;s+$DES_NV+despair.nvim+;s/Files //;s/ differ//;s/ and /\|/")"

if [ $FILE_DIFF_NUM -gt 0 ]; then
    echo "=== Found $FILE_DIFF_NUM sync conflicts ==="
    echo ""
    echo -e "$FILE_DIFFS_PRETTY" | while read line; do
        DF_A="$(echo "$line" | cut -d "|" -f 1)"
        DF_B="$(echo "$line" | cut -d "|" -f 2)"
        printf "%-40s => %s\n" "$DF_A" "$DF_B"
    done
    echo ""
    if ! confirm "Do you merge them and continue? [y/N]: "; then
        exit 0
    fi

    echo -e "$FILE_DIFFS_PRETTY" | while read line; do
        DF_A="$(echo -e "$line" | cut -d "|" -f 1)"
        DF_B="$(echo -e "$line" | cut -d "|" -f 2)"
        printf "%-40s => %s\n" "$DF_A" "$DF_B"
        wait_for_input
        # Merge from despair into monolith
        df_merge "$XDG_CONFIG_HOME/$DF_B" "$XDG_CONFIG_HOME/$DF_A"
    done
else
    echo "No sync conflicts detected, proceeding to sync"
fi
echo ""

DIR_SYNCS="$(echo -e "$DIR_SYNCS" | sed '/^$/d')"
FILE_SYNCS="$(echo -e "$FILE_SYNCS" | sed '/^$/d')"

__sync_dirs_all

MERGED_DIR="/tmp/vimsync$XDG_CONFIG_HOME/monolith.nvim"

if confirm "Do you want to explore merged directories? [y/N]: "; then
    nvim "$MERGED_DIR" +"cd \"$MERGED_DIR\""
fi
if confirm_y "Apply synced dirs to distros? [Y/n]: "; then
    echo -e "$DIR_SYNCS" | while read line; do
        DF_A="$(echo -e "$line" | cut -d "|" -f 1)"
        DF_B="$(echo -e "$line" | cut -d "|" -f 2)"
        rm -rf "$DF_A"/** 
        rm -rf "$DF_B"/**
    done

    cp -rf "$MERGED_DIR"/** "$XDG_CONFIG_HOME/monolith.nvim/"
    cp -rf "$MERGED_DIR"/** "$XDG_CONFIG_HOME/despair.nvim/"
fi

echo -e "$FILE_SYNCS" | while read line; do
    DF_A="$(echo -e "$line" | cut -d "|" -f 1)"
    DF_B="$(echo -e "$line" | cut -d "|" -f 2)"
    cp -f "$DF_A" "$DF_B"
done

echo "Successfully synced neovim distributions"

