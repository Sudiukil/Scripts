# Winget wrapper script with enriched functionality

# Read config from ~/.winget-wrapper.json
Function Read-Config {
  $jsonConfig = "$env:USERPROFILE\.winget-wrapper.json"

  # Return the config as an object
  Return [PSCustomObject]@{
    Blacklist = (Get-Content $jsonConfig | jq -r ".blacklist[]") -Split '\r?\n'
  }
}

# Builds a list of installed packages, with blacklisting support
Function List-Packages {
  # Export and list currently installed packages
  winget export -o "$env:TEMP\winget.json" >$null
  $packages = (Get-Content $env:TEMP\winget.json | jq -r ".Sources[].Packages[].PackageIdentifier") -Split '\r?\n'

  # Filter out blackisted packages
  $upgradablePackages = $packages | Where-Object { $config.Blacklist -notcontains $_ }

  Return [PSCustomObject]@{
    All = $packages
    Blacklisted = $config.Blacklist
    Upgradable = $upgradablePackages
  }
}

# `upgrade --all` substitute, with blacklisting support
Function Upgrade-All-Wrapper {
  Write-Output "Using wrapped function..."

  # Get upgradable (non blacklisted) packages
  $packages = (List-Packages).Upgradable
  $packageCount = $packages.Length

  # Loop through all packages and upgrade them
  For ($i = 0; $i -lt $packageCount; $i++) {
    $packageId = $packages[$i]
    $progress = [Math]::Ceiling(($i + 1) / $packageCount * 100)
    Write-Progress -Id $PID -Activity "Upgrading all packages" -Status "$progress% Upgrading $packageId..." -PercentComplete $progress

    winget upgrade --id $packageId >$null
  }

  Write-Output "Done!"
}

# Upgrade arguments parser
Function Upgrade-Wrapper([Array]$params) {
  Switch ($params[0]) {
    "--all" { Upgrade-All-Wrapper }
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