#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)/scripts/common.sh"

link_config "$repo_dir/claude/settings.json" "$HOME/.claude/settings.json"
link_config "$repo_dir/claude/agents" "$HOME/.claude/agents"
