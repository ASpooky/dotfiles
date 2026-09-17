#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)/scripts/common.sh"

if [[ "$platform" == Darwin ]]; then
  vscode_user_dir="$HOME/Library/Application Support/Code/User"
else
  vscode_user_dir="$config_dir/Code/User"
fi

# The macOS app includes its CLI even when `code` is not on PATH yet.
code_bin="$(command -v code || true)"
if [[ -z "$code_bin" && "$platform" == Darwin ]]; then
  for app_dir in "${mac_app_dirs[@]}"; do
    candidate="$app_dir/Visual Studio Code.app/Contents/Resources/app/bin/code"
    if [[ -x "$candidate" ]]; then
      code_bin="$candidate"
      break
    fi
  done
fi

if [[ -n "$code_bin" ]]; then
  installed_extensions="$("$code_bin" --list-extensions)"
  link_config "$repo_dir/vscode/settings.json" "$vscode_user_dir/settings.json"
  while IFS= read -r extension || [[ -n "$extension" ]]; do
    [[ -z "$extension" || "$extension" == \#* ]] && continue
    if printf '%s\n' "$installed_extensions" | grep -Fxiq -- "$extension"; then
      printf 'Already installed: %s\n' "$extension"
    else
      "$code_bin" --install-extension "$extension"
    fi
  done < "$repo_dir/vscode/extensions.txt"
  printf 'Reload the VS Code window if open.\n'
else
  printf 'Skipping VS Code settings and extensions: CLI not found. Install VS Code and rerun setup.sh.\n'
fi
