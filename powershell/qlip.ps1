# Script for quickly extracting a clip from a video file using ffmpeg
# Requires ffmpeg

param(
  [string] $InputFile,
  [string] $StartTimestamp,
  [string] $EndTimestamp,
  [int] $QuickClip
)
  
# Needed to load the generated clip into the clipboard
Add-Type -AssemblyName System.Windows.Forms

# Constants
$SOURCE_DIR = "E:\Vidéos\Captures\OBS"
$DEST_FILE = "$env:USERPROFILE\Desktop\clip.mp4"
$SCRIPT_NAME = $MyInvocation.MyCommand.Path | Split-Path -Leaf

# Generate a clip from the input file
# The clip is created using ffmpeg with the specified start and end timestamps
# The output file is saved to the desktop with the name "clip.mp4"
# The audio streams are merged into one using the amerge filter
# The video is encoded using the hevc_nvenc codec with a constant quality of 20
# The output frame rate is set to 60 fps
function Write-Clip {
  param(
    [string] $InputFile,
    [string] $StartTimestamp,
    [string] $EndTimestamp
  )

  ffmpeg -y -ss "$StartTimestamp" -to "$EndTimestamp" -i "$InputFile" -filter_complex "[0:a:0][0:a:1][0:a:2]amerge=inputs=3[aout]" -map 0:v -map "[aout]" -c:v hevc_nvenc -preset p4 -cq 20 -r 60 -c:a aac -ac 2 $DEST_FILE
}

# Function to get the latest .mkv file from the source directory, for quick clips
function Get-LatestSourceClip {
  $latestFile = Get-ChildItem -Path $SOURCE_DIR -Filter "*.mkv" -File |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

  if ($latestFile) {
    return $latestFile.FullName
  }
  else {
    Write-Host "No .mkv files found in $SOURCE_DIR."
    return $null
  }
}

# Show usage if no (or invalid) parameters are provided
function Show-Usage {
  Write-Host "Usage:"
  Write-Host "`t$SCRIPT_NAME -QuickClip <seconds>"
  Write-Host "`t$SCRIPT_NAME -InputFile <source.mkv> -StartTimestamp <start> -EndTimestamp <end>"
}

if ($QuickClip -ge 10 -and $QuickClip -le 60) {
  $InputFile = (Get-LatestSourceClip)
  $StartTimestamp = "00:14:$(60 - $QuickClip)"
  $EndTimestamp = "00:15:00"
}
elseif (-not $InputFile -or -not $StartTimestamp -or -not $EndTimestamp -or -not (Test-Path $InputFile)) {
  Show-Usage
  exit 1
}

# Generate the clip
Write-Clip -InputFile $InputFile -StartTimestamp $StartTimestamp -EndTimestamp $EndTimestamp

# Create a StringCollection and add the file path
$fileCollection = New-Object System.Collections.Specialized.StringCollection
$fileCollection.Add($DEST_FILE)

# Copy the file to the clipboard
[System.Windows.Forms.Clipboard]::SetFileDropList($fileCollection)

Write-Host "Clip created and copied to clipboard: $DEST_FILE"