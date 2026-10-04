. "$PSScriptRoot\..\scripts\common.ps1"

# The GlazeWM package also installs Zebar, which config.yaml starts.
Install-WingetPackage 'glzr-io.glazewm'
Copy-ConfigFile "$repo_dir\glazewm\config.yaml" "$HOME\.glzr\glazewm\config.yaml"

$glazewm_exe = "$env:ProgramFiles\glzr.io\GlazeWM\glazewm.exe"
New-StartupShortcut 'GlazeWM' $glazewm_exe

if (Get-Process glazewm -ErrorAction SilentlyContinue) {
    & "$env:ProgramFiles\glzr.io\GlazeWM\cli\glazewm.exe" command wm-reload-config
    Write-Host 'Reloaded GlazeWM config.'
} else {
    Start-Process $glazewm_exe
    Write-Host 'Started GlazeWM.'
}
