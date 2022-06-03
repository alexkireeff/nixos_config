# zsh settings
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=0
setopt nomatch
unsetopt appendhistory autocd beep extendedglob notify
bindkey -v

# personal settings
alias ls='ls -lashFv'
alias clean='sudo apt clean -y; sudo apt update -y; sudo apt upgrade -y; sudo apt autoremove --purge -y'
alias shutdown='sudo shutdown -r now'
export EDITOR='nvim'

alias gitGraph='git log --all --decorate --oneline --graph'
