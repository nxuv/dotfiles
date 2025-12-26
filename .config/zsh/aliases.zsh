alias l="ls -l"
alias lf="ls -lF"
alias la="ls -a"
alias ll="ls -aghl"

alias fs="cd -"
alias ..='cd ../'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias mkdir='mkdir -pv'
alias mv="mv -i"
alias cp="cp -i"
alias ln="ln -i"

alias wttr='curl wttr.in/Moscow'

alias clear-nvim-swap='echo "Removing nvim swap."; rm -rf ~/.local/state/nvim/swap'

alias fix-clock='sudo ntpd -qg && sudo hwclock -w'

alias j="fg %\$(jobs | awk '!/^(\()/' | gum choose | awk '{print substr(\$0, 2, 1)}')"

# alias srcrc="exec zsh"
alias srcrc="source $XDG_CONFIG_HOME/zsh/.zshrc"

__has eza       && alias ls="eza"
__has fetch     && alias cls="clear && source $XDG_CONFIG_HOME/zsh/motd.zsh"

__has bat       && alias bat="bat --plain"
__has bat       && alias bathelp='bat=--plain --language=help'
__has feh       && alias feh="feh -Tdefault"
__has ncal      && alias calendar='ncal -yMb'

__has musikcube && alias music="musikcube"
__has nvim      && alias nv="nvim"

__has dart      && alias pub="dart pub"
__has reuse     && alias reuse="reuse --suppress-deprecation"

__has egrep     && alias egrep="egrep --color=auto"
__has fgrep     && alias fgrep="fgrep --color=auto"
__has grep      && alias grep="grep --color=auto"

__has zathura   && alias pdf="detach zathura"

__has elinks    && alias el="elinks"

__has xclip     && alias xclip="xclip -sel c"

( __has fzf && __has fc-list ) && alias ls-fonts='fc-list  --format="%{family[0]} %{style[0]}\n" | sort | uniq | fzf'
( __has mpv && __has gum )     && alias play='mpv "$(gum file)"'

if __has onefetch; then
    # used in cd hook
    alias onefetch='onefetch --true-color never --no-title -d authors -d churn -d lines-of-code -d commits --no-color-palette'
    alias gitfetch='onefetch -d created -d last-change -d project -d url -d size --no-art -d languages -d contributors -d version -d license'
    alias gitshort='gitfetch | tr "\n" " "; echo '''
fi

if __has buckle; then
    # clickity clackity motherfucker
    alias buckle-start='buckle -f & disown'
    alias buckle-stop='pkill buckle'
fi

if __has qtile; then
    alias qtile-reload="qtile cmd-obj -o cmd -f reload_config"
    alias qtile-restart="qtile cmd-obj -o cmd -f restart"
fi


