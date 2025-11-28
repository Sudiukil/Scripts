# Winget backup and restore script

param(
  [switch]$Backup,
  [switch]$Restore
)

# Define paths for export and backup files
$ExportPath = "$env:TEMP\winget-export.json"
$BackupPath = "$env:USERPROFILE\Documents\winget-backup.txt"

# Define a blacklist of package IDs to exclude from backup
$PackagesBlacklist = @(
  "Nvidia.PhysX",
  "Microsoft.Edge",
  "Microsoft.VCRedist.2015+.x86",
  "Microsoft.VCRedist.2012.x86",
  "Futuremark.FuturemarkSystemInfo",
  "Microsoft.VCRedist.2012.x64",
  "Microsoft.VCRedist.2015+.x64",
  "Microsoft.AppInstaller",
  "Microsoft.UI.Xaml.2.7",
  "Microsoft.UI.Xaml.2.8",
  "Microsoft.VCLibs.Desktop.14"
)

# Backups a filtered list of Winget packages IDs to a text file
function Backup-WingetPackages {
  # Clear previous backup file
  Set-Content -Path "$BackupPath" -Value $null -Force

  # Export installed packages to JSON and read the file
  winget.exe export -s winget -o "$ExportPath" | Out-Null
  $data = Get-Content -Path "$ExportPath" | ConvertFrom-Json

  # Filter and write package identifiers to backup file
  $data.Sources[0].Packages | ForEach-Object {
    if ($PackagesBlacklist -notcontains $_.PackageIdentifier) {
      Add-Content -Path "$BackupPath" -Value ($_.PackageIdentifier)
    }
  }

  Write-Host "Backup completed. Packages IDs saved to $BackupPath."
}

# Restores Winget packages from the backup text file
function Restore-WingetPackages {
  if (Test-Path -Path "$BackupPath") {
    $packageIds = Get-Content -Path "$BackupPath"
    
    foreach ($packageId in $packageIds) {
      $Command = "winget.exe install --id $packageId"
      Write-Host "Running: $Command"
      Invoke-Expression $Command
    }
  }
  else {
    Write-Host "Backup file not found at $BackupPath"
  }
}

# Displays usage information
function Show-Usage {
  Write-Host "Usage: winget-backup.ps1 -Backup | -Restore"
  Write-Host "`t-Backup : Export installed winget packages to backup file."
  Write-Host "`t-Restore: Install packages from backup file."
}

# Main script logic

if ($Backup) {
  Backup-WingetPackages
}
elseif ($Restore) {
  Restore-WingetPackages
}
else {
  Show-Usage
}