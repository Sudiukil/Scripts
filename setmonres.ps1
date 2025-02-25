# Wrapper script to set monitor resolution and refresh rate using NirCmd
# Requires: NirCmd (http://www.nirsoft.net/utils/nircmd.html)

# Input parameters
param(
  [int] $Resolution,
  [int] $RefreshRate,
  [switch] $Help
)

# Get the script name
$ScriptName = [System.IO.Path]::GetFileName($PSCommandPath)

# Acceptable resolutions and refresh rates
$AspectRatio = 16 / 9
$ValidResolutions = @(1080, 1620, 2160)
$ValidRefreshrates = @(60, 144)

# Function to show usage information
function Show-Usage {
  $usage = @"
Sets the monitor resolution and refresh rate using NirCmd.

Usage: $ScriptName -Resolution <resolution> -RefreshRate <refresh rate>

Parameters:
  -Resolution   The vertical resolution of the monitor (accepted values: $($ValidResolutions -join ", ")).
  -RefreshRate  The refresh rate of the monitor (accepted values: $($ValidRefreshrates -join ", ")).

Example:
  $ScriptName -Resolution 1080 -RefreshRate 144

Requirements:
  NirCmd (http://www.nirsoft.net/utils/nircmd.html)
"@
  Write-Output $usage
}

# Function to show usage reminder
function Show-UsageReminder {
  Write-Output "See $ScriptName -Help for usage information."
}

# Check if the Help switch is provided
if ($Help) {
  Show-Usage
  exit 0
}

# Check if the required parameters are provided
if ($Resolution -notin $ValidResolutions) {
  Write-Error "Invalid resolution. Valid resolutions are: $($ValidResolutions -join ", ")."
  Show-UsageReminder
  exit 1
}

if ($RefreshRate -notin $ValidRefreshRates) {
  Write-Error "Invalid refresh rate. Valid refresh rates are: $($ValidRefreshRates -join ", ")."
  Show-UsageReminder
  exit 1
}

# Calculate the horizontal resolution based on the aspect ratio
$HorizontalResolution = $Resolution * $AspectRatio

# Show the resolution and refresh rate
Write-Output "Setting monitor resolution to $HorizontalResolution x $Resolution @ $RefreshRate Hz."

# Construct the arguments for NirCmd
$nircmdArgs = "setdisplay $HorizontalResolution $Resolution 32 $RefreshRate -updatereg"

# Execute NirCmd using Start-Process
Start-Process -FilePath "nircmd.exe" -ArgumentList $nircmdArgs -NoNewWindow -Wait