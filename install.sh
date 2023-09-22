#!/bin/sh

# Script for "installing" scripts

LINUX_BIN_DIR="$HOME/.bin"
WINDOWS_BIN_DIR="$USERPROFILE/.bin"

# Linux
if [ -d "$LINUX_BIN_DIR" ]; then
  find . -type f \( -name "*.sh" -o -name "*.rb" \) -printf "%P\n" | while read -r i; do
    ln -sf "$PWD/$i" "$LINUX_BIN_DIR/$(basename "${i%.*}")"
  done
  chmod +x "$LINUX_BIN_DIR"/*
else
  echo "No ~/.bin dir found, skipping Linux scripts..."
fi

# Windows
if [ -d "$WINDOWS_BIN_DIR" ]; then
  find . -type f -name "*.ps1" -printf "%P\n" | while read -r i; do
    cp "$PWD/$i" "$WINDOWS_BIN_DIR/$(basename "${i%.*}")"
  done
else
  echo "No \$USERPROFILE/.bin dir found, skipping Windows scripts..."
fi

exit 0