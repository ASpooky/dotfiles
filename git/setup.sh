#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)/scripts/common.sh"

require_command git

link_config "$repo_dir/git/config" "$config_dir/git/config"
link_config "$repo_dir/git/ignore" "$config_dir/git/ignore"

# `git config --global` writes to the XDG file (the repo) when ~/.gitconfig is missing.
touch "$HOME/.gitconfig"

if command -v git-secrets >/dev/null 2>&1; then
  if git config --global --get-all secrets.providers | grep -Fq 'git secrets --aws-provider'; then
    printf 'Already registered: git-secrets AWS patterns\n'
  else
    git secrets --register-aws --global
  fi
else
  printf 'Skipping git-secrets: not installed. Rerun after the brew component.\n'
fi

if [[ -z "$(git config --global user.email || true)" ]]; then
  printf 'Set your identity: git config --global user.name "..." && git config --global user.email "..."\n'
fi
