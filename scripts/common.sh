#!/usr/bin/env bash
# Shared by the component setup scripts.
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
backup_dir=""
export PATH="$HOME/.local/bin:$PATH"
platform="$(uname -s)"
mac_app_dirs=(/Applications "$HOME/Applications")
case "$platform" in
  Darwin|Linux) ;;
  *) printf 'Supported platforms: macOS and Linux.\n' >&2; exit 1 ;;
esac

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Install %s, then rerun setup.\n' "$1" >&2
    exit 1
  fi
}

link_config() {
  local source="$1" target="$2" saved
  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    printf 'Already linked: %s\n' "$target"
    return
  fi
  mkdir -p "$(dirname "$target")"
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -z "$backup_dir" ]]; then
      mkdir -p "$HOME/.dotfiles-backups"
      backup_dir="$(mktemp -d "$HOME/.dotfiles-backups/setup-$(date +%Y%m%d-%H%M%S)-XXXXXX")"
      printf 'Backup directory: %s\n' "$backup_dir"
    fi
    saved="$backup_dir$target"
    mkdir -p "$(dirname "$saved")"
    mv "$target" "$saved"
    printf 'Backed up: %s -> %s\n' "$target" "$saved"
  fi
  ln -s "$source" "$target"
  printf 'Linked: %s\n' "$target"
}
