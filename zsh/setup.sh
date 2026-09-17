#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)/scripts/common.sh"

require_command git
require_command zsh

install_plugin() {
  local name="$1" target="$HOME/.zsh/plugins/$1"
  if [[ -f "$target/$name.zsh" ]]; then
    printf 'Already installed: %s\n' "$name"
    return
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    printf 'Incomplete plugin directory: %s. Move it aside and rerun.\n' "$target" >&2
    exit 1
  fi
  git clone --depth 1 "https://github.com/zsh-users/$name.git" "$target"
}

mkdir -p "$HOME/.zsh/plugins"
install_plugin zsh-autosuggestions
install_plugin zsh-syntax-highlighting

link_config "$repo_dir/zsh/.zshrc" "${ZDOTDIR:-$HOME}/.zshrc"
printf 'Open a new zsh terminal or run: exec zsh -l\n'
if [[ "${SHELL:-}" != *"/zsh" ]]; then
  printf 'To make zsh your login shell, run: chsh -s "%s"\n' "$(command -v zsh)"
fi
