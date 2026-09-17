#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)/scripts/common.sh"

require_command curl

if ! command -v mise >/dev/null 2>&1; then
  installer="$(mktemp)"
  trap 'rm -f "$installer"' EXIT
  curl --fail --silent --show-error --location https://mise.run -o "$installer"
  MISE_INSTALL_PATH="$HOME/.local/bin/mise" sh "$installer"
fi

mise_config="${MISE_GLOBAL_CONFIG_FILE:-${MISE_CONFIG_DIR:-$config_dir/mise}/config.toml}"
link_config "$repo_dir/mise/config.toml" "$mise_config"
# Avoid inheriting configuration from the caller's project.
cd "$HOME"
mise install
