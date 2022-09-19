#!/bin/sh

# Wrapper script for winget

WINGET=/mnt/c/Users/qsonrel/AppData/Local/Microsoft/WindowsApps/winget.exe
LOCK_PATH="$HOME/.winget.lock"

# Adds a --safe that'll upgrade all packages except those listed in ~/.winget.lock (ids only)
# Useful for pinning versions (to the one currently installed) since winget doesn't handle that
upgrade() {
  case $1 in
    --safe) $WINGET upgrade | rev | grep "tegniw" | tr -s ' ' | cut -d ' ' -f 4 | rev | grep -vf "$LOCK_PATH" | while read -r id; do $WINGET upgrade --id "$id"; done;;
    *) $WINGET upgrade "$@";;
  esac
}

case $1 in
  upgrade) shift; upgrade "$@";;
  *) $WINGET "$@";;
esac

exit 0