## Created by Zap installer
if [ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ]; then
    source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
else
    zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --b release-v1 --k
fi

alias zap-uninstall 'rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/zap"'

plug "zsh-users/zsh-autosuggestions"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

plug "zsh-users/zsh-syntax-highlighting"

plug "zsh-users/zsh-history-substring-search"

