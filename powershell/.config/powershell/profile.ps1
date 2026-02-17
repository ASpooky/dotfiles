# PowerShell profile — minimal

# --- PSReadLine ---
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# --- Starship ---
Invoke-Expression (&starship init powershell)
