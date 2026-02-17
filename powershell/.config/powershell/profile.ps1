# PowerShell profile — minimal

# --- PSReadLine ---
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# --- Git completion (posh-git) ---
Import-Module posh-git

# --- Starship ---
Invoke-Expression (&starship init powershell)
