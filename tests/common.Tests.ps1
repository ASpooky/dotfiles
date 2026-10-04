# Run on Windows: Invoke-Pester tests (Pester 3.4+)
. "$PSScriptRoot\..\scripts\common.ps1"

Describe 'Read-ListFile' {
    It 'skips blank lines and comments' {
        $list = Join-Path $TestDrive 'list.txt'
        Set-Content $list "# comment`n`n  first  `nsecond"
        $result = @(Read-ListFile $list)
        $result.Count | Should Be 2
        $result[0] | Should Be 'first'
        $result[1] | Should Be 'second'
    }

    It 'strips trailing comments' {
        $list = Join-Path $TestDrive 'list.txt'
        Set-Content $list 'ABC123 # Some plugin'
        Read-ListFile $list | Should Be 'ABC123'
    }
}

Describe 'Read-Utf8File' {
    It 'reads UTF-8 without BOM and normalizes line endings' {
        $path = Join-Path $TestDrive 'utf8.txt'
        # Non-ASCII via char codes: Windows PowerShell reads BOM-less scripts as ANSI.
        $japanese = [string][char]0x65E5 + [char]0x672C
        [IO.File]::WriteAllText($path, "$japanese`r`nline", (New-Object Text.UTF8Encoding $false))
        Read-Utf8File $path | Should Be "$japanese`nline"
    }
}

Describe 'Copy-ConfigFile' {
    BeforeEach {
        $script:backup_dir = $null
        $env:DOTFILES_BACKUP_ROOT = Join-Path $TestDrive 'backups'
        $source = Join-Path $TestDrive 'source.yaml'
        $target = Join-Path $TestDrive 'app\config.yaml'
        Remove-Item (Join-Path $TestDrive 'app'), $env:DOTFILES_BACKUP_ROOT -Recurse -Force -ErrorAction SilentlyContinue
        Set-Content $source 'new'
    }

    It 'creates the target and its parent directory' {
        Copy-ConfigFile $source $target
        Get-Content $target | Should Be 'new'
    }

    It 'leaves an identical target untouched without a backup' {
        New-Item (Split-Path $target) -ItemType Directory | Out-Null
        Copy-Item $source $target
        Copy-ConfigFile $source $target
        Test-Path $env:DOTFILES_BACKUP_ROOT | Should Be $false
    }

    It 'backs up a different target before replacing it' {
        New-Item (Split-Path $target) -ItemType Directory | Out-Null
        Set-Content $target 'old'
        Copy-ConfigFile $source $target
        Get-Content $target | Should Be 'new'
        $saved = @(Get-ChildItem $env:DOTFILES_BACKUP_ROOT -Recurse -Filter config.yaml)
        $saved.Count | Should Be 1
        Get-Content $saved[0].FullName | Should Be 'old'
    }
}

Describe 'ConvertTo-PortableFlowSettings' {
    $json = @'
{
  "Hotkey": "Alt + Space",
  "WindowLeft": 670,
  "WindowTop": 248,
  "ActivateTimes": 3,
  "CustomPluginHotkeys": [],
  "PluginSettings": {
    "Plugins": {
      "ABC": { "ID": "ABC", "Version": "2.1.3", "ActionKeywords": ["b"] }
    }
  }
}
'@
    $text = ConvertTo-PortableFlowSettings $json
    $result = $text | ConvertFrom-Json

    It 'emits LF line endings with a trailing newline' {
        $text.Contains("`r") | Should Be $false
        $text.EndsWith("}`n") | Should Be $true
    }

    It 'keeps user preferences' {
        $result.Hotkey | Should Be 'Alt + Space'
    }

    It 'drops machine- and usage-dependent keys' {
        $names = $result.PSObject.Properties.Name
        $names -contains 'WindowLeft' | Should Be $false
        $names -contains 'WindowTop' | Should Be $false
        $names -contains 'ActivateTimes' | Should Be $false
    }

    It 'drops plugin versions so updates do not show up as diffs' {
        $result.PluginSettings.Plugins.ABC.PSObject.Properties.Name -contains 'Version' | Should Be $false
    }

    It 'keeps arrays as arrays' {
        $result.PluginSettings.Plugins.ABC.ActionKeywords -is [array] | Should Be $true
        $result.CustomPluginHotkeys -is [array] | Should Be $true
    }
}
