# ~/.zshrc — minimal

# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS

# --- Completion ---
autoload -Uz compinit && compinit -C
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

# --- PATH ---
typeset -U path
path=(
  "${HOME}/.local/bin"
  "${HOME}/go/bin"
  "/usr/local/go/bin"
  $path
)

# --- Starship ---
eval "$(starship init zsh)"
