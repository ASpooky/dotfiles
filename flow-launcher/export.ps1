# Copies the live Flow Launcher settings and plugin list back into the repository.
. "$PSScriptRoot\..\scripts\common.ps1"

$data_dir = "$env:APPDATA\FlowLauncher"

Write-Utf8File "$repo_dir\flow-launcher\Settings.json" (ConvertTo-PortableFlowSettings (Read-Utf8File "$data_dir\Settings\Settings.json"))

$plugins = Get-ChildItem "$data_dir\Plugins\*\plugin.json" -ErrorAction SilentlyContinue |
    ForEach-Object { Read-Utf8File $_.FullName | ConvertFrom-Json } |
    Sort-Object Name |
    ForEach-Object { "$($_.ID) # $($_.Name)" }
$lines = @(
    '# Third-party Flow Launcher plugins, by ID from the official plugin manifest.'
    '# After installing plugins with `pm install`, regenerate with flow-launcher/export.ps1.'
) + @($plugins)
Write-Utf8File "$repo_dir\flow-launcher\plugins.txt" (($lines -join "`n") + "`n")

Write-Host "Exported: $repo_dir\flow-launcher"
