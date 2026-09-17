#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)/scripts/common.sh"

link_config "$repo_dir/terminal-design/starship.toml" "${STARSHIP_CONFIG:-$config_dir/starship.toml}"
