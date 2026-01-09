# Normal PATH
# typeset -U PATH PATH

try_add_path() {
    [ -d "$1" ] && export PATH="$PATH:$1"
}

try_add_path "/sbin"
try_add_path "/bin"
try_add_path "/usr/sbin"
try_add_path "/usr/bin"
try_add_path "/usr/local/bin"
try_add_path "$XDG_DATA_HOME/npm/bin"
try_add_path "$XDG_DATA_HOME/bin"
try_add_path "$HOME/.dot/scripts/ext-git"
try_add_path "$HOME/.dot/scripts/ext-kiss"
try_add_path "$HOME/.dot/scripts"
try_add_path "$HOME/.bin"
# TODO: move it to own place (since kiss is best package manager)
try_add_path "$XDG_DATA_HOME/python/bin"
try_add_path "$HOME/.go/bin"
try_add_path "$HOME/.cargo/bin"
try_add_path "$HOME/.dotnet/"
try_add_path "$HOME/.appimages"

# TODO: check if it exists
if [ -d "$XDG_DATA_HOME/gem/ruby" ]; then
    [ ! -d "$XDG_DATA_HOME/gem/ruby/dummy/bin" ] && mkdir -p "$XDG_DATA_HOME/gem/ruby/dummy/bin"
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
export EDITOR="/bin/nvim"
export FILE_PICKER_CMD="nnn"
export HAS_ALLOW_UNSAFE="y"
export HOMEBREW_NO_ENV_HINTS=true
export PAGER="/bin/less"
export MANPAGER="$PAGER"
export LESS="--use-color -R"
export NAP_THEME="gruvbox"
export RANGER_LOAD_DEFAULT_RC=false
export SHELL="/bin/zsh"
export STARSHIP_LOG="error"
export TERM="xterm-256color"
export WEBKIT_DISABLE_COMPOSITING_MODE=1

export SVDIR="$HOME/.sv"

# artix-dark-theme-git
export GTK_THEME="Artix-dark"
export QT_QPA_PLATFORMTHEME="qt5ct"

# Program PATH env
export CARGO_HOME="$HOME/.cargo"
export GOPATH="$HOME/.go"
export INVDIR="$XDG_DATA_HOME/inventory"
export NODE_PATH="$XDG_DATA_HOME/npm/lib/node_modules"
export BUNDLE_PATH="$XDG_DATA_HOME/gem"
export PYTHONPATH="$XDG_DATA_HOME/python"

# export RUBY_ROOT=/usr/lib/ruby/gems/3.0.0
export RUSTUP_HOME="$HOME/.rustup"
export ZK_NOTEBOOK_DIR="$HOME/zk"
export LYNX_CFG="$XDG_CONFIG_HOME/lynx/lynx.cfg"
[ -d "/g" ] && export DEVDOCS_DIR="/g/devdocs/" || export DEVDOCS_DIR="$XDG_DATA_HOME/devdocs/"

export JUST_TEMPDIR="/tmp"

export WEB_PAGER="/bin/elinks"
export KISS_PATH="$XDG_DATA_HOME/kiss"

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

export NNN_FIFO='/tmp/nnn.fifo'

# Perl

export PATH="$HOME/perl5/bin${PATH:+:${PATH}}"
export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
export PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
export PERL_MB_OPT="--install_base \"$HOME/perl5\""
export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"

