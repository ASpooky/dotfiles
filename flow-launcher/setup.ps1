. "$PSScriptRoot\..\scripts\common.ps1"

Install-WingetPackage 'Flow-Launcher.Flow-Launcher'

$data_dir = "$env:APPDATA\FlowLauncher"
$settings_path = "$data_dir\Settings\Settings.json"
$repo_settings = "$repo_dir\flow-launcher\Settings.json"
$flow_exe = "$env:LOCALAPPDATA\FlowLauncher\Flow.Launcher.exe"
$manifest_url = 'https://raw.githubusercontent.com/Flow-Launcher/Flow.Launcher.PluginsManifest/plugin_api_v2/plugins.json'

# Flow Launcher rewrites window positions and counters on every run, so
# compare only the portable part against the repository.
$settings_current = (Test-Path $settings_path) -and
    (ConvertTo-PortableFlowSettings (Read-Utf8File $settings_path)) -eq (Read-Utf8File $repo_settings)

$installed_ids = @(Get-ChildItem "$data_dir\Plugins\*\plugin.json" -ErrorAction SilentlyContinue |
    ForEach-Object { (Read-Utf8File $_.FullName | ConvertFrom-Json).ID })
$missing_ids = @(Read-ListFile "$repo_dir\flow-launcher\plugins.txt" | Where-Object { $installed_ids -notcontains $_ })

if ($settings_current -and $missing_ids.Count -eq 0) {
    Write-Host "Already up to date: $settings_path"
    Write-Host 'Already installed: Flow Launcher plugins'
    return
}

# Flow Launcher saves its settings on exit, which would overwrite ours.
$was_running = [bool](Get-Process Flow.Launcher -ErrorAction SilentlyContinue)
Get-Process Flow.Launcher -ErrorAction SilentlyContinue | Stop-Process -Force -PassThru | Wait-Process

if (-not $settings_current) {
    Copy-ConfigFile $repo_settings $settings_path
}

if ($missing_ids.Count -gt 0) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $manifest = Invoke-RestMethod $manifest_url
    foreach ($id in $missing_ids) {
        $plugin = $manifest | Where-Object ID -eq $id
        if (-not $plugin) {
            Write-Warning "Plugin not found in the manifest: $id"
            continue
        }
        $work_dir = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid())
        try {
            New-Item $work_dir -ItemType Directory | Out-Null
            Invoke-WebRequest $plugin.UrlDownload -OutFile "$work_dir\plugin.zip" -UseBasicParsing
            Expand-Archive "$work_dir\plugin.zip" "$work_dir\extracted"
            # Some archives wrap the plugin in a top-level folder.
            $plugin_root = (Get-ChildItem "$work_dir\extracted" -Recurse -Filter plugin.json | Select-Object -First 1).DirectoryName
            New-Item "$data_dir\Plugins" -ItemType Directory -Force | Out-Null
            Move-Item $plugin_root "$data_dir\Plugins\$($plugin.Name)-$($plugin.Version)"
            Write-Host "Installed plugin: $($plugin.Name) $($plugin.Version)"
        } finally {
            Remove-Item $work_dir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Start-Process $flow_exe
if ($was_running) { Write-Host 'Restarted Flow Launcher.' } else { Write-Host 'Started Flow Launcher.' }
