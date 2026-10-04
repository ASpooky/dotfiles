#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
failed=()

# Other components use the tools that these two install.
setups=("$repo_dir/brew/setup.sh" "$repo_dir/mise/setup.sh")
for setup in "$repo_dir"/*/setup.sh; do
  case "$setup" in
    */brew/setup.sh|*/mise/setup.sh) ;;
    *) setups+=("$setup") ;;
  esac
done

for setup in "${setups[@]}"; do
  [[ -f "$setup" ]] || continue
  component="$(basename "$(dirname "$setup")")"
  printf '\nSetting up %s...\n' "$component"
  if ! bash "$setup"; then
    printf 'Failed: %s\n' "$component" >&2
    failed+=("$component")
  fi
done

if [[ ${#failed[@]} -gt 0 ]]; then
  printf '\nSetup finished with failures: %s\n' "${failed[*]}" >&2
  exit 1
fi

printf '\nSetup complete.\n'
