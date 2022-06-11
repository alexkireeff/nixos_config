# make nvim default editor
export EDITOR="nvim"
alias vi="nvim"
alias vim="nvim"

# no history file
HISTFILE=/dev/null
# store last 1000 commands in memory
HISTSIZE=1000
# no historry file (redundant)
SAVEHIST=0
setopt nomatch
unsetopt appendhistory autocd beep extendedglob notify
# set zsh to vi mode
# bindkey prints to stdout
bindkey -a > /dev/null

# personal settings
alias ls='ls -lashFv'
alias cleanHome='sudo -E nix-env -e home-manager-path; sudo -E home-manager-switch'
alias cleanComp='sudo nixos-rebuild switch'
# TODO need shutdown?
alias shutdown='sudo shutdown -r now'
alias tmux='tmux -2'
alias gitGraph='git log --all --decorate --oneline --graph'
