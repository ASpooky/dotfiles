# Windows entry point. Run from PowerShell:
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1
$ErrorActionPreference = 'Stop'
$failed = @()

foreach ($setup in Get-ChildItem "$PSScriptRoot\*\setup.ps1") {
    $component = $setup.Directory.Name
    Write-Host "`nSetting up $component..."
    # Each component runs in its own process so one failure does not stop the rest.
    & powershell -NoProfile -ExecutionPolicy Bypass -File $setup.FullName
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed: $component" -ForegroundColor Red
        $failed += $component
    }
}

if ($failed.Count -gt 0) {
    Write-Host "`nSetup finished with failures: $($failed -join ' ')" -ForegroundColor Red
    exit 1
}
Write-Host "`nSetup complete."
