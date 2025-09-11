# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc
alias vim="nvim"

if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" >/dev/null
  ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi
