
#########################################################################
##! Set Aliases
#########################################################################
Set-Alias subl "C:\Program Files (x86)\Sublime Text 2\sublime_text.exe"

#########################################################################
##! Set Functions
#########################################################################
set-content function:\mklink "cmd /c mklink `$args"

function LL {
<#
.Synopsis
  Returns childitems with colors by type.
.Description
  This function wraps Get-ChildItem and tries to output the results
  color-coded by type:
  Compressed - Yellow
  Directories - Dark Cyan
  Executables - Green
  Text Files - Cyan
  Others - Default
.ReturnValue
  All objects returned by Get-ChildItem are passed down the pipeline
  unmodified.
.Notes
  NAME:      Get-ChildItemColor
  AUTHOR:    Tojo2000 <tojo2000@tojo2000.com>
#>
  $regex_opts = ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase `
      -bor [System.Text.RegularExpressions.RegexOptions]::Compiled)
 
  $fore = $Host.UI.RawUI.ForegroundColor
  $compressed = New-Object System.Text.RegularExpressions.Regex(
      '\.(zip|tar|gz|rar)$', $regex_opts)
  $executable = New-Object System.Text.RegularExpressions.Regex(
      '\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg|ru|rb)$', $regex_opts)
  $text_files = New-Object System.Text.RegularExpressions.Regex(
      '\.(txt|cfg|conf|ini|csv|log)$', $regex_opts)
 
  $count = 0
  Invoke-Expression ("Get-ChildItem $args") |
    %{
      $count++
      if ($count -gt 1){
        if ($_.GetType().Name -eq 'DirectoryInfo') {
          $Host.UI.RawUI.ForegroundColor = 'DarkCyan'
          echo $_
          $Host.UI.RawUI.ForegroundColor = $fore
        } elseif ($compressed.IsMatch($_.Name)) {
          $Host.UI.RawUI.ForegroundColor = 'Yellow'
          echo $_
          $Host.UI.RawUI.ForegroundColor = $fore
        } elseif ($executable.IsMatch($_.Name)) {
          $Host.UI.RawUI.ForegroundColor = 'Green'
          echo $_
          $Host.UI.RawUI.ForegroundColor = $fore
        } elseif ($text_files.IsMatch($_.Name)) {
          $Host.UI.RawUI.ForegroundColor = 'Cyan'
          echo $_
          $Host.UI.RawUI.ForegroundColor = $fore
        } else {
          echo $_
        }
      } else {
        echo $_
      }
    }
}

Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Load posh-git module from current directory
Import-Module "C:\Users\David\Code\posh-git\posh-git"

# If module is installed in a default location ($env:PSModulePath),
# use this instead (see about_Modules for more information):
# Import-Module posh-git


# Set up a simple prompt, adding the git prompt parts inside git repos
$global:CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
function prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    Write-Host('(') -nonewline -foregroundcolor White

    Write-Host($env:USERNAME) -nonewline -foregroundcolor DarkGray
    Write-Host('@') -nonewline -foregroundcolor Gray
    Write-Host($env:COMPUTERNAME) -nonewline -foregroundcolor DarkGray
    Write-Host(')') -nonewline -foregroundcolor White
    Write-Host($(get-location)) -nonewline -foregroundcolor White

    Write-VcsStatus -nonewline

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

Enable-GitColors

Pop-Location

Start-SshAgent -Quiet


