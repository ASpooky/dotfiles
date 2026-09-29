#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)/scripts/common.sh"

if ! command -v brew >/dev/null 2>&1; then
  printf 'Skipping Homebrew packages: brew not found. Install Homebrew and rerun setup.sh.\n'
  exit 0
fi

brew bundle --file "$repo_dir/brew/Brewfile" --no-upgrade
