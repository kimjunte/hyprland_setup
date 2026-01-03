# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc
alias vim="nvim"

if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" >/dev/null
  ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi

alias k9slog="sshfs kimjunte@192.168.0.181:/home/kimjunte/.local/state/k9s/screen-dumps/microk8s-cluster/microk8s ~/logs"
export EDITOR=vim
export VISUAL=vim

alias mist="ssh kimjunte@192.168.0.181"
alias misto="ssh kimjunte@mealcraft.com"
alias filesync="sshfs kimjunte@192.168.0.181:/home/kimjunte/github ~/github"
alias filesynco="sshfs kimjunte@mealcraft.com:/home/kimjunte/github ~/github"
alias code_local="code --remote ssh-remote+kimjunte@192.168.1.181 /home/kimjunte"
alias code_online="code --remote ssh-remote+kimjunte@mealcraft.com /home/kimjunte"
