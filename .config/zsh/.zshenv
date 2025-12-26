# Normal PATH
# typeset -U PATH PATH

export PATH="$PATH:/sbin"
export PATH="$PATH:/bin"
export PATH="$PATH:/usr/sbin"
export PATH="$PATH:/usr/bin"
export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:$HOME/.local/share/npm/bin"
export PATH="$PATH:$HOME/.local/share/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.dot/scripts/git_scripts"
export PATH="$PATH:$HOME/.dot/scripts"
export PATH="$PATH:$HOME/.bin"
export PATH="$PATH:$HOME/.go/bin"
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/.dotnet/"
export PATH="$PATH:$HOME/.appimages"

# TODO: check if it exists
if [ -d "$XDG_DATA_HOME/gem/ruby" ]; then
    [ ! -d "$XDG_DATA_HOME/gem/ruby/dummy/bin" ] mkdir -p "$XDG_DATA_HOME/gem/ruby/dummy/bin"
    for dir in $XDG_DATA_HOME/gem/ruby/*/bin; do
        [ -d "$dir" ] && export PATH="$PATH:$dir"
    done
fi

# export PATH="$(echo "$PATH" | awk -v RS=':' -v ORS=":" '!a[$1]++{if (NR > 1) printf ORS; printf $a[$1]}')"

# zsh config
if [ ! -f "$XDG_DATA_HOME/zsh/history" ]; then
    mkdir -p "$XDG_DATA_HOME/zsh/"
    touch    "$XDG_DATA_HOME/zsh/history"
fi

export HISTFILE="$XDG_DATA_HOME/zsh/history"
export HISTZIE="8192"
export SAVEHIST="8192"

# Misc env
export DXVK_ASYNC=1
export EDITOR="/usr/bin/nvim"
export FILE_PICKER_CMD="nnn"
export HAS_ALLOW_UNSAFE="y"
export HOMEBREW_NO_ENV_HINTS=true
export MANPAGER="$PAGER"
export NAP_THEME="gruvbox"
export PAGER="less --use-color -R"
export RANGER_LOAD_DEFAULT_RC=false
export SHELL="/bin/zsh"
export STARSHIP_LOG="error"
export TERM="xterm-256color"
export WEBKIT_DISABLE_COMPOSITING_MODE=1

# artix-dark-theme-git
export GTK_THEME="Artix-dark"
export QT_QPA_PLATFORMTHEME="qt5ct"

# Program PATH env
export CARGO_HOME="$HOME/.cargo/"
export GOPATH="$HOME/.go/"
export INVDIR="$HOME/.local/share/inventory"
export NODE_PATH="$XDG_DATA_HOME/npm/lib/node_modules"
export BUNDLE_PATH="$XDG_DATA_HOME/gem"
# export RUBY_ROOT=/usr/lib/ruby/gems/3.0.0
export RUSTUP_HOME="$HOME/.rustup"
export ZK_NOTEBOOK_DIR="$HOME/zk"
export LYNX_CFG="$XDG_CONFIG_HOME/lynx/lynx.cfg"
[ -d "/g" ] && export DEVDOCS_DIR="/g/devdocs/" || export DEVDOCS_DIR="$XDG_DATA_HOME/devdocs/"

export JUST_TEMPDIR="/tmp"

# export NNN_PLUG="p:-!less -iR '$nnn'*;d:-!gum confirm 'Delete $nnn?' && rm '$nnn'"
export NNN_PLUG='d:dragdrop;x:!chmod +x "$nnn"*;X:!chmod -x "$nnn"*;f:!bat --tabs 4 --color always --theme ansi --paging always --style=plain,numbers -n "$nnn"*'
# Order                     Hex     Color
# Block_device              c1      DarkSeaGreen1
# Char_device               e2      Yellow1
# Directory                 27      DeepSkyBlue1
# Executable                2e      Green1
# Regular                   00      Normal
# Hard_link                 60      Plum4
# Symbolic_link             33      Cyan1
# Missing_OR_file           details f7 Grey62
# Orphaned_symbolic         link    c6 DeepPink1
# FIFO                      d6      Orange1
# Socket                    ab      MediumOrchid1
# Unknown_OR_0B_regular/exe c4      Red1
#                    | | | | | | | | | | |
export NNN_FCOLORS="0203040200050608030501"
# NNN_FCOLORS='c1e2272e006033f7c6d6abc4'
# NNN_COLORS='1234' ('#0a1b2c3d'/'#0a1b2c3d;1234')

export NNN_OPTS="H"

