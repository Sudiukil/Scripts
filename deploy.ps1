# Scripts management script for Windows installations
# Note: requires developer mode to be enabled in Windows settings

# Resolves the root directory of the script, with relative symlink support
function Resolve-ScriptsRoot {
  $Script = Get-Item $PSCommandPath

  # If the script is a symlink, resolve its target and return its parent directory
  if ($null -ne $Script.Target) {
    return $Script.Target | Resolve-Path | Split-Path -Parent
  }

  # Otherwise, return the parent directory of the script
  return $Script | Split-Path -Parent
}

# Installs PowerShell scripts by creating symbolic links in the user's .bin directory
function Install-Scripts {
  $ScriptsRoot = "$(Resolve-ScriptsRoot)\powershell"
  $BinDir = "$env:USERPROFILE\.bin"

  if (!(Test-Path $BinDir)) {
    New-Item -ItemType Directory -Path "$BinDir"
  }

  Get-ChildItem -Path "$ScriptsRoot" -Filter "*.ps1" | ForEach-Object {
    New-Item -ItemType SymbolicLink -Path "$BinDir\$($_.Name)" -Target "$($_.FullName)" -Force
  }
}

Install-Scripts