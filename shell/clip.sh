#!/bin/sh

# Script for writting into Windows clipboard from WSL
# clip.exe doesn't (always) play nice with UTF-8, so...
# Requires pwsh to be a **Windows executable** (i.e. a symlink to whatever PowerShell executable you have installed on Windows)

# Read the script piped input to a variable
while read -r line; do
  # No line breaks for the first line
  [ -z "${input+x}" ] && input="$line" && continue

  # Append the next lines with a PowerShell line break
  input="$input\`n$line"
done

# Write the variable to the Windows clipboard, via PowerShell
echo "$input" | pwsh -NoProfile -Command "Set-Clipboard -Value \"$input\""

exit 0