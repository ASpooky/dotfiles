# Shared by the Windows component setup scripts.
$ErrorActionPreference = 'Stop'

$repo_dir = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$backup_dir = $null

# Keys that change with window position, usage or app updates; keeping them
# in the repository would only produce noisy diffs.
$flow_volatile_keys = @(
    'WindowLeft', 'WindowTop', 'CustomWindowLeft', 'CustomWindowTop',
    'PreviousScreenWidth', 'PreviousScreenHeight', 'PreviousDpiX', 'PreviousDpiY',
    'SettingWindowTop', 'SettingWindowLeft', 'SettingWindowState',
    'SettingWindowWidth', 'SettingWindowHeight',
    'ActivateTimes', 'ReleaseNotesVersion'
)

function Read-ListFile([string]$Path) {
    Get-Content $Path | ForEach-Object { ($_ -replace '#.*$', '').Trim() } | Where-Object { $_ }
}

function Read-Utf8File([string]$Path) {
    [IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8) -replace "`r`n", "`n"
}

function Write-Utf8File([string]$Path, [string]$Text) {
    [IO.File]::WriteAllText($Path, $Text, (New-Object Text.UTF8Encoding $false))
}

function Copy-ConfigFile([string]$Source, [string]$Target) {
    if ((Test-Path $Target) -and
        (Get-FileHash $Source).Hash -eq (Get-FileHash $Target).Hash) {
        Write-Host "Already up to date: $Target"
        return
    }
    New-Item (Split-Path $Target) -ItemType Directory -Force | Out-Null
    if (Test-Path $Target) {
        if (-not $script:backup_dir) {
            $root = if ($env:DOTFILES_BACKUP_ROOT) { $env:DOTFILES_BACKUP_ROOT } else { Join-Path $HOME '.dotfiles-backups' }
            $script:backup_dir = Join-Path $root ('setup-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
            Write-Host "Backup directory: $script:backup_dir"
        }
        $saved = Join-Path $script:backup_dir ($Target -replace '^[A-Za-z]:', '' -replace '^\\\\', '')
        New-Item (Split-Path $saved) -ItemType Directory -Force | Out-Null
        Move-Item $Target $saved
        Write-Host "Backed up: $Target -> $saved"
    }
    Copy-Item $Source $Target
    Write-Host "Copied: $Target"
}

function ConvertTo-PortableFlowSettings([string]$Json) {
    $settings = $Json | ConvertFrom-Json
    foreach ($key in $flow_volatile_keys) {
        $settings.PSObject.Properties.Remove($key)
    }
    if ($settings.PluginSettings -and $settings.PluginSettings.Plugins) {
        foreach ($plugin in $settings.PluginSettings.Plugins.PSObject.Properties) {
            $plugin.Value.PSObject.Properties.Remove('Version')
        }
    }
    ((ConvertTo-Json $settings -Depth 20) -replace "`r`n", "`n") + "`n"
}

function Test-WingetPackage([string]$Id) {
    winget list --id $Id --exact --accept-source-agreements *> $null
    $LASTEXITCODE -eq 0
}

function Install-WingetPackage([string]$Id) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'winget was not found. Install "App Installer" from Microsoft Store, then rerun setup.'
    }
    if (Test-WingetPackage $Id) {
        Write-Host "Already installed: $Id"
        return
    }
    winget install --id $Id --exact --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { throw "winget install failed: $Id (exit $LASTEXITCODE)" }
}

function New-StartupShortcut([string]$Name, [string]$TargetPath) {
    $shortcut_path = Join-Path ([Environment]::GetFolderPath('Startup')) "$Name.lnk"
    if (Test-Path $shortcut_path) {
        Write-Host "Already registered at startup: $Name"
        return
    }
    $shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($shortcut_path)
    $shortcut.TargetPath = $TargetPath
    $shortcut.Save()
    Write-Host "Registered at startup: $Name"
}
