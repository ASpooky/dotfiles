#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)/scripts/common.sh"

link_config "$repo_dir/claude/settings.json" "$HOME/.claude/settings.json"
link_config "$repo_dir/claude/agents" "$HOME/.claude/agents"
link_config "$repo_dir/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

if [[ -f "$HOME/.claude/skills/herdr/SKILL.md" ]]; then
  printf 'Already installed: herdr skill\n'
elif command -v npx >/dev/null 2>&1; then
  npx -y skills add ogulcancelik/herdr --skill herdr --global --agent claude-code --yes
else
  printf 'Skipping herdr skill: npx not found. Rerun after the mise component.\n'
fi
