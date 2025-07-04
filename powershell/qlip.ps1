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
function Write-Clip {
  param(
    [string] $InputFile,
    [string] $StartTimestamp,
    [string] $EndTimestamp
  )

  $ffmpegArgs = @(
    "-y"                           # Overwrite output file without asking
    "-ss", "$StartTimestamp"       # Start time for the clip
    "-to", "$EndTimestamp"         # End time for the clip
    "-i", "$InputFile"             # Input file
    "-filter_complex", "[0:a:0][0:a:1][0:a:2]amerge=inputs=3[aout]" # Merge audio streams
    "-map", "0:v"                  # Map the first video stream
    "-map", "[aout]"               # Map the merged audio stream
    "-c:v", "hevc_nvenc"           # Use the NVIDIA HEVC encoder
    "-preset", "p4"                # Use the p4 preset for faster encoding
    "-cq", "28"                    # Set constant quality to 28
    "-r", "60"                     # Set output frame rate to 60 fps
    "-c:a", "aac"                  # Use AAC for audio encoding
    "-ac", "2"                     # Set number of audio channels to 2 (stereo)
    "$DEST_FILE"                   # Output file path
  )
  & ffmpeg @ffmpegArgs
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

### Main script

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