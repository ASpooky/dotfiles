# Copies the live GlazeWM config back into the repository.
. "$PSScriptRoot\..\scripts\common.ps1"

Copy-Item "$HOME\.glzr\glazewm\config.yaml" "$repo_dir\glazewm\config.yaml"
Write-Host "Exported: $repo_dir\glazewm\config.yaml"
