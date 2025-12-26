alias l="ls -l"
alias lf="ls -lF"
alias la="ls -a"
alias ll="ls -aghl"

# alias logout="exit"
alias logoff="exit"
alias logon="login"

alias fs="cd -"
alias ..='cd ../'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias clear="printf '\033c'"
alias scratch='tput smcup && tput clear'
alias normal='tput rmcup'

alias mkdir='mkdir -pv'
alias mv="mv -i"
alias cp="cp -i"
alias ln="ln -i"

alias make-ls="grep : makefile | awk -F: '/^[^.]/ {print \$1;}'"
alias Make-ls="grep : Makefile | awk -F: '/^[^.]/ {print \$1;}'"

alias wttr='curl wttr.in/Moscow'

alias clearvswap='echo "Removing nvim swap."; rm -rf ~/.local/state/nvim/swap'

alias pacman-time='sudo ntpd -qg && sudo hwclock -w'
alias pacman-clean='pacman -Qtdq | sudo pacman -Rns -'

alias j="fg %\$(jobs | awk '!/^(\()/' | gum choose | awk '{print substr(\$0, 2, 1)}')"

# alias srcrc="exec zsh"
alias srcrc="source $XDG_CONFIG_HOME/zsh/.zshrc"

__has eza       && alias ls="eza"
__has fetch     && alias cls="clear && source $XDG_CONFIG_HOME/zsh/motd.zsh"
__has pkm       && alias pkg="pkm"
__has shpool    && alias sesh="shpool"
__has trash     && alias rm="trash"

__has bat       && alias bat="bat --plain"
__has bat       && alias bathelp='bat=--plain --language=help'
__has feh       && alias feh="feh -Tdefault"
__has fman      && alias fman="fman --theme gruvbox --icons none"
__has ncal      && alias calendar='ncal -yMb'
__has tty-clock && alias clock='tty-clock -s -c -C 7'

__has cmatrix   && alias cmatrix='cmatrix -C yellow'
__has hr        && alias line="hr ─"
__has musikcube && alias music="musikcube"
__has nms       && alias nms='nms -a'
__has pxv       && alias getcat="pxv -U https://cataas.com/cat -s fit"
__has taskbook  && alias tb="taskbook"
__has telnet    && alias mapscii='telnet mapscii.me'

__has dart      && alias pub="dart pub"
__has reuse     && alias reuse="reuse --suppress-deprecation"

__has trans     && alias tenru="trans -e google -I -hl en -t ru"
__has trans     && alias truen="trans -e google -I -hl ru -t en"

__has egrep     && alias egrep="egrep --color=auto"
__has fgrep     && alias fgrep="fgrep --color=auto"
__has grep      && alias grep="grep --color=auto"

__has qtile     && alias qtile-restart='qtile cmd-obj -o cmd -f restart'

__has zathura   && alias pdf="detach zathura"

__has elinks    && alias el="elinks"

__has xclip     && alias xclip="xclip -sel c"

( __has fzf && __has fc-list ) && alias ls-fonts='fc-list  --format="%{family[0]} %{style[0]}\n" | sort | uniq | fzf'

if __has nvim; then
    alias nv=nvim
fi

if __has onefetch; then
    alias onefetch='onefetch --true-color never --no-title -d authors -d churn -d lines-of-code -d commits --no-color-palette'
    alias gitfetch='onefetch -d created -d last-change -d project -d url -d size --no-art -d languages -d contributors -d version -d license'
    alias gitshort='gitfetch | tr "\n" " "; echo '''
fi

if __has buckle; then
    alias buckle-start='buckle -f & disown'
    alias buckle-stop='pkill buckle'
fi

if __has qtile; then
    alias qtile-reload="qtile cmd-obj -o cmd -f reload_config"
    alias qtile-restart="qtile cmd-obj -o cmd -f restart"
fi

if __has mpv; then
    alias play='mpv "$(gum file)"'
fi


