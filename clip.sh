#!/bin/sh

# Script for sharing clipboard between WSL and Windows
# Requires the used pwsh executable to be the Windows one

while read -r line
do
  pwsh -NoProfile -Command Set-Clipboard -Value "$line"
done

exit 0