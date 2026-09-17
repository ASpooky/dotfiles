#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)/scripts/common.sh"

if [[ "$platform" != Darwin ]]; then
  printf 'Skipping Raycast: macOS only.\n'
  exit 0
fi

for app_dir in "${mac_app_dirs[@]}"; do
  if [[ -d "$app_dir/Raycast.app" ]]; then
    printf 'Already installed: %s/Raycast.app\n' "$app_dir"
    exit 0
  fi
done

require_command curl
os_version="$(sw_vers -productVersion)"
os_major="${os_version%%.*}"
case "$(uname -m)" in
  arm64) build=arm ;;
  x86_64) build=x86_64 ;;
  *) printf 'Skipping Raycast: unsupported architecture.\n'; exit 0 ;;
esac

# Raycast 2 requires Apple Silicon and macOS Tahoe; older Macs use Raycast 1.
if [[ "$build" == arm && "$os_major" -ge 26 ]]; then
  download_url='https://x.raycast-releases.com/download?platform=macos&architecture=arm64'
elif [[ "$os_major" -ge 13 ]]; then
  download_url="https://releases.raycast.com/download?build=$build"
else
  printf 'Skipping Raycast: install a compatible version manually on this macOS.\n'
  exit 0
fi

work_dir="$(mktemp -d)"
mount_dir="$work_dir/mount"
mounted=false
cleanup() {
  if [[ "$mounted" == true ]]; then
    hdiutil detach "$mount_dir" -quiet || return
  fi
  rm -rf "$work_dir"
}
trap cleanup EXIT

curl --fail --location --show-error --retry 3 "$download_url" -o "$work_dir/Raycast.dmg"
mkdir "$mount_dir"
hdiutil attach "$work_dir/Raycast.dmg" -mountpoint "$mount_dir" -nobrowse -readonly -quiet
mounted=true
if [[ ! -d "$mount_dir/Raycast.app" ]]; then
  printf 'Raycast.app was not found in the downloaded disk image.\n' >&2
  exit 1
fi

# Stage the copy before moving it into place; never merge into an existing app.
ditto "$mount_dir/Raycast.app" "$work_dir/Raycast.app"
install_dir="${mac_app_dirs[1]}"
mkdir -p "$install_dir"
if [[ -e "$install_dir/Raycast.app" || -L "$install_dir/Raycast.app" ]]; then
  printf 'Raycast appeared during setup; leaving it unchanged.\n'
  exit 0
fi
mv "$work_dir/Raycast.app" "$install_dir/Raycast.app"
printf 'Installed: %s/Raycast.app. Open Raycast to finish onboarding.\n' "$install_dir"
