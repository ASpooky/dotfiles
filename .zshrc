# Locally installed tools; keep PATH entries unique.
typeset -U path
path=("$HOME/.local/bin" $path)
export PATH

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE EXTENDED_HISTORY

# Enable completion without requiring a plugin manager.
autoload -Uz compinit
compinit

if [[ -r "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

[[ ! -r "$HOME/.secrets" ]] || source "$HOME/.secrets"

if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

# Load after completion, hooks, and other plugins.
if [[ -r "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
