#Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$DotfilesDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Info  { param($Msg) Write-Host "[INFO]  $Msg" -ForegroundColor Cyan }
function Write-Ok    { param($Msg) Write-Host "[OK]    $Msg" -ForegroundColor Green }
function Write-Skip  { param($Msg) Write-Host "[SKIP]  $Msg" -ForegroundColor Yellow }

# --- 1. Starship ---
Write-Info "Starship をインストール"
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Write-Skip "Starship はインストール済み"
} else {
    winget install --id Starship.Starship --accept-source-agreements --accept-package-agreements
    Write-Ok "Starship をインストールしました"
}

# --- 2. posh-git ---
Write-Info "posh-git をインストール"
if (Get-Module -ListAvailable -Name posh-git) {
    Write-Skip "posh-git はインストール済み"
} else {
    Install-Module posh-git -Scope CurrentUser -Force
    Write-Ok "posh-git をインストールしました"
}

# --- 3. Nerd Font ---
Write-Info "JetBrainsMono Nerd Font をインストール"
$fontInstalled = winget list --id DEVCOM.JetBrainsMonoNerdFont 2>$null |
    Select-String "JetBrainsMonoNerdFont"
if ($fontInstalled) {
    Write-Skip "JetBrainsMono Nerd Font はインストール済み"
} else {
    winget install --id DEVCOM.JetBrainsMonoNerdFont --accept-source-agreements --accept-package-agreements
    Write-Ok "JetBrainsMono Nerd Font をインストールしました"
}

# --- 4. シンボリックリンク (profile.ps1) ---
Write-Info "profile.ps1 のシンボリックリンクを作成"
$profileDir = "$HOME\Documents\WindowsPowerShell"
$profileLink = "$profileDir\Microsoft.PowerShell_profile.ps1"
$profileTarget = "$DotfilesDir\powershell\.config\powershell\profile.ps1"

New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
if (Test-Path $profileLink) {
    $item = Get-Item $profileLink
    if ($item.LinkType -eq "SymbolicLink" -and $item.Target -contains $profileTarget) {
        Write-Skip "profile.ps1 のシンボリックリンクは作成済み"
    } else {
        Write-Host "  既存の profile.ps1 があります: $profileLink" -ForegroundColor Yellow
        $ans = Read-Host "  上書きしますか? [y/N]"
        if ($ans -match "^[Yy]$") {
            Remove-Item $profileLink -Force
            New-Item -ItemType SymbolicLink -Path $profileLink -Target $profileTarget | Out-Null
            Write-Ok "profile.ps1 のシンボリックリンクを作成しました"
        } else {
            Write-Skip "profile.ps1 のシンボリックリンク作成をスキップ"
        }
    }
} else {
    New-Item -ItemType SymbolicLink -Path $profileLink -Target $profileTarget | Out-Null
    Write-Ok "profile.ps1 のシンボリックリンクを作成しました"
}

# --- 5. シンボリックリンク (starship.toml) ---
Write-Info "starship.toml のシンボリックリンクを作成"
$configDir = "$HOME\.config"
$starshipLink = "$configDir\starship.toml"
$starshipTarget = "$DotfilesDir\starship\.config\starship.toml"

New-Item -ItemType Directory -Path $configDir -Force | Out-Null
if (Test-Path $starshipLink) {
    $item = Get-Item $starshipLink
    if ($item.LinkType -eq "SymbolicLink" -and $item.Target -contains $starshipTarget) {
        Write-Skip "starship.toml のシンボリックリンクは作成済み"
    } else {
        Write-Host "  既存の starship.toml があります: $starshipLink" -ForegroundColor Yellow
        $ans = Read-Host "  上書きしますか? [y/N]"
        if ($ans -match "^[Yy]$") {
            Remove-Item $starshipLink -Force
            New-Item -ItemType SymbolicLink -Path $starshipLink -Target $starshipTarget | Out-Null
            Write-Ok "starship.toml のシンボリックリンクを作成しました"
        } else {
            Write-Skip "starship.toml のシンボリックリンク作成をスキップ"
        }
    }
} else {
    New-Item -ItemType SymbolicLink -Path $starshipLink -Target $starshipTarget | Out-Null
    Write-Ok "starship.toml のシンボリックリンクを作成しました"
}

Write-Host ""
Write-Ok "セットアップ完了！PowerShell を再起動してください。"
Write-Host "  ターミナルのフォントを 'JetBrainsMono Nerd Font' に変更してください。" -ForegroundColor Cyan
