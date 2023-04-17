# Winget wrapper script with enriched functionality

# Read config from ~/.winget-wrapper.json
Function Read-Config {
  $jsonConfig = "$env:USERPROFILE\.winget-wrapper.json"

  # Return the config as an object
  Return [PSCustomObject]@{
    Blacklist = (Get-Content $jsonConfig | jq -r ".blacklist[]") -Split '\r?\n'
  }
}

# `upgrade --all` substitute, with blacklisting support
Function Upgrade-All-With-Blacklist {
  Write-Output "Using wrapped function..."

  # Export and list currently installed packages
  winget export -o "$env:TEMP\winget.json" >$null
  $packages = Get-Content $env:TEMP\winget.json | jq -r ".Sources[].Packages[].PackageIdentifier"
  $packageCount = $packages.Length

  # Loop over installed packages and update each if no blacklist match is found
  For ($i = 0; $i -lt $packageCount; $i++) {
    $packageId = $packages[$i]
    $pcent = [Math]::Ceiling(($i + 1) / $packageCount * 100)
    Write-Progress -Id $PID -Activity "Upgrading all packages" -Status "$pcent% Upgrading $packageId..." -PercentComplete $pcent

    If (!$config.Blacklist.Contains($packageId)) {
      winget upgrade --id $packageId >$null
    }
  }
}

# Upgrade arguments parser
Function Upgrade-Wrapper([Array]$params) {
  Switch ($params[0]) {
    "--all" { Upgrade-All-With-Blacklist }
    default { winget upgrade $params }
  }
}

# Main arguments parser
Function Parse-Args([Array]$params) {
  Switch ($params[0]) {
    "upgrade" { Upgrade-Wrapper($params[1..$params.Length]) }
    default { winget $params }
  }
}

Set-Alias winget "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps\winget.exe"
$config = Read-Config
Parse-Args($args)