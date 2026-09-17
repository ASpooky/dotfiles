#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)/scripts/common.sh"

if [[ "$platform" != Darwin ]]; then
  printf 'Skipping cmux: macOS only.\n'
  exit 0
fi

# cmux uses this canonical path independently of XDG_CONFIG_HOME.
cmux_bin="$(command -v cmux || true)"
if [[ -z "$cmux_bin" ]]; then
  for app_dir in "${mac_app_dirs[@]}"; do
    candidate="$app_dir/cmux.app/Contents/MacOS/cmux"
    if [[ -x "$candidate" ]]; then
      cmux_bin="$candidate"
      break
    fi
  done
fi
if [[ -n "$cmux_bin" ]]; then
  link_config "$repo_dir/cmux/cmux.json" "$HOME/.config/cmux/cmux.json"
  printf 'Reload cmux configuration (Cmd+Shift+,) if open.\n'
else
  printf 'Skipping cmux: app not found. Install it and rerun setup.sh.\n'
fi
