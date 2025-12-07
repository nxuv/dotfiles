__echoerr() {
    echo -e "\e[91;1m$@\e[0m"
}

detach() {
    $@ & disown
}

silent() {
    tfile="$(mktemp)"
    echo "Redirecting output to '$tfile'"
    nohup $@ > $tfile &
}

clean-dir() {
    /bin/rm -rf ".Trash-1000"
    /bin/rm -rf "\$RECYCLE.BIN"
    /bin/rm -rf "System Volume Information"
    /bin/rm -rf "pagefile.sys"
}

clean-dir-force() {
    sudo /bin/rm -rf ".Trash-1000"
    sudo /bin/rm -rf "\$RECYCLE.BIN"
    sudo /bin/rm -rf "System Volume Information"
    sudo /bin/rm -rf "pagefile.sys"
}

psearch() {
    if [ $# -gt 0 ]; then
        ps axu | grep $@[1]
    else
        echo "Please supply process name"
    fi
}

cheat() {
    curl cheat.sh/$@
}

scrape() {
    if [ $# -gt 0 ]; then
        ddir="$(echo $@ | sed -e 's/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/')-$(date +'%Y-%m-%d')"
        echo -e "\e[1mWebsite \"$@\" will now be scraped\e[0m"
        echo -e "\e[1mDownload dir is \"$ddir\"\e[0m"
        echo -e "\e[2mThis will take a while since\e[0m"
        echo -e "\e[2meach request will be made in\e[0m"
        echo -e "\e[2mbetween 1 and 3 seconds\e[0m"
        echo ""
        wget -r -p -l 10 -E -k -N -w 2 --random-wait $@ -P $ddir
    else
        __echoerr "Please supply website address"
    fi
}

remetamp3() {
    filein=$@

    read -P "Title: " title
    read -P "Artist: " artist
    read -P "Album artist: " album_artist
    read -P "Album: " album
    read -P "Year: " year
    read -P "Track: " track
    read -P "Genre: " genre
    read -P "Comment: " comment

    ffmpeg -loglevel panic -i $filein \
        -metadata title=$title \
        -metadata artist=$artist \
        -metadata album_artist=$album_artist \
        -metadata album=$album \
        -metadata year=$year \
        -metadata track=$track \
        -metadata genre=$genre \
        -metadata comment=$comment \
        -c:a copy "$track. $artist - $title - out.mp3"
}

switch-theme() {
    THEME_NAME_FILE="$XDG_CONFIG_HOME/env_theme_name"

    if [ $# -gt 0 ]; then
        if [ ! -f "$THEME_NAME_FILE" ] && touch "$THEME_NAME_FILE"
        if [[ "$@" == "gruvbox" ]]; then
            # gruvbox
            echo "gruvbox" > $THEME_NAME_FILE
        elif [[ "$@" == "despair" ]]; then
            # despair
            echo "despair" > $THEME_NAME_FILE
        elif ( [[ "$@" == "-l" ]] || [[ "$@" == "--list" ]] ); then
            echo -e "Supported themes:\n    gruvbox\n    despair"
        elif ( [[ "$@" == "-h" ]] || [[ "$@" == "--help" ]] ); then
            echo "Usage:"
            echo "    switch-theme [flags|theme_name]"
            echo ""
            echo "Flags:"
            echo "    -l, --list - Lists supported theme names"
            echo "    -h, --help - Prints this message"
        else
            __echoerr -e "Unsupported theme name '$@'"
            return 1
        fi

        __has qtile && qtile-reload

        return 0
    fi
    __echoerr "Missing theme name"
}

if __has $HOME/.dotfiles/unbin/t.py; then
    t() {
        __T_DIR="$HOME/.config/tasks"
        if [[ "$1" == '-s' || "$1" == "--sync" ]]; then
            echo "> Syncing tasks with git repo,"
            if [ $(git -C "$__T_DIR" status -s | wc -l) -eq 0 ]; then
                echo "> no local changes detected, fetching remote,"
                git -C "$__T_DIR" pull origin master
            else
                echo "> found local changes, fast-forwarding to remote,"
                git -C "$__T_DIR" pull --ff origin master
                echo "> pushing local changes."
                git -C "$__T_DIR" add .
                git -C "$__T_DIR" commit -m "$(date -u)"
                git -C "$__T_DIR" push origin master
            fi
            echo "> Sync complete."
        elif [[ "$1" == '-c' || "$1" == "--cd" ]]; then
            cd "$__T_DIR"
        elif [[ "$1" == '-h' || "$1" == "--help" ]]; then
            $HOME/.dotfiles/unbin/t.py --help
            echo ''
            echo "  Custom Options:"
            echo "    -s, --sync          sync git repo"
            echo "    -c, --cd            cd into task dir"
        else
            $HOME/.dotfiles/unbin/t.py -t "$__T_DIR" $@
        fi
    }
fi

if __has $HOME/.dotfiles/unbin/confed; then
    conf() {
        if [ $# -gt 0 ]; then
            if [[ "$@" == "-"* ]]; then
                ~/.dotfiles/unbin/confed $@
                return 0
            fi
            tmp_path="$(~/.dotfiles/unbin/confed -p $@)"
            if [[ "$tmp_path" == "" ]]; then
                echo "Failed to find config or encoutered an error"
            else
                [ -f $tmp_path ] && cd "$(dirname $tmp_path)" || cd $tmp_path
                $EDITOR $tmp_path
            fi
        else
            echo "Please supply config name"
        fi
    }
fi

if __has selectrepodir.js; then
    repos() {
        cd $(selectrepodir.js)
    }
fi

if __has nvim; then
    # nvim-switch() {
    #     nvim_current="$(basename $(readlink ~/.config/nvim))"
    #     rm ~/.config/nvim
    #     if [[ "$nvim_current" == "monolith.nvim" ]]; then
    #         echo "Current configuration is $nvim_current"
    #         ln -sf ~/.config/despair.nvim ~/.config/nvim
    #     else
    #         echo "Current configuration is $nvim_current"
    #         ln -sf ~/.config/monolith.nvim ~/.config/nvim
    #     fi
    #     echo "Set Neovim configuration to $(basename $(readlink ~/.config/nvim))"
    # }

    # nvim-set-config() {
    #     if [ ! -d "$XDG_CONFIG_HOME/$@" ]; then
    #         echo "Supplied config directory doesn't exist"
    #         return 1
    #     fi
    #     rm ~/.config/nvim
    #     ln -sf "$XDG_CONFIG_HOME/$@" "$XDG_CONFIG_HOME/nvim"
    # }

    nvmerge() {
        if ( [[ "$@" == "-h" ]] || [[ "$@" == "--help" ]] ); then
            echo "Usage:"
            echo "    nvmerge [from] [into]"
            echo ""
            echo "Description:"
            echo "    Diffs [from] and [into] and pipes output of diff"
            echo "    into neovim while setting filename to [into]"
            return 0
        fi
        if [ $# -lt 2 ]; then
            __echoerr "Must provide two files for mergins"
            return 1
        fi
        merge -A -q -p $2 $1 $2 | nvim +"file $2"
    }
fi

if __has yadm; then
    yadm-add() {
        yadm add -u
        yadm add ~/.local/share/nvim/templates -f
        yadm add ~/.local/share/qutebrowser/greasemonkey -f
        yadm add ~/.dotfiles
        yadm add ~/.config/wezterm
        yadm add ~/.config/qtile
    }
fi

if __has boxes; then
    b-warn() {
        echo "$@" | boxes -d warning --no-color
    }
    b-info() {
        echo "$@" | boxes -d info --no-color
    }
    b-crit() {
        echo "$@" | boxes -d critical --no-color
    }
fi

if __has nnn; then
    n () {
        # Block nesting of nnn in subshells
        [ "${NNNLVL:-0}" -eq 0 ] || {
            echo "nnn is already running"
            return
        }

        # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
        # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
        # see. To cd on quit only on ^G, remove the "export" and make sure not to
        # use a custom path, i.e. set NNN_TMPFILE *exactly* as follows:
        #      NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
        export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

        # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
        # stty start undef
        # stty stop undef
        # stty lwrap undef
        # stty lnext undef

        # The command builtin allows one to alias nnn to n, if desired, without
        # making an infinitely recursive alias
        command nnn "$@"

        [ ! -f "$NNN_TMPFILE" ] || {
            . "$NNN_TMPFILE"
            rm -f -- "$NNN_TMPFILE" > /dev/null
        }
    }
fi

if [[ "$(uname -n)" == "Helios" ]]; then
    # alias boot-apollo='sudo grub-reboot Apollo && sudo shutdown -r 0'
    boot-apollo() {
        sudo sed -i -e '/saved_entry/c\saved_entry=Apollo' /boot/grub/grubenv
        sudo shutdown -r now
    }
fi

