#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

for setup in "$repo_dir"/*/setup.sh; do
  [[ -f "$setup" ]] || continue
  component="$(basename "$(dirname "$setup")")"
  printf '\nSetting up %s...\n' "$component"
  bash "$setup"
done

printf '\nSetup complete.\n'
