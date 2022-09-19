#!/bin/sh
# shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common.sh"

# Wrapper script for winget

WINGET="$USERPROFILE/AppData/Local/Microsoft/WindowsApps/winget.exe"
LOCK_PATH="$HOME/.winget.lock"

[ -f "$WINGET" ] || log "ERROR" "winget binary isn't available."

# Adds a --safe that'll upgrade all packages except those listed in ~/.winget.lock (ids only)
# Useful for pinning versions (to the one currently installed) since winget doesn't handle that
upgrade() {
  case $1 in
    --safe)
      [ -f "$LOCK_PATH" ] || log "ERROR" "Lock file not found."
      $WINGET upgrade | rev | grep "tegniw" | tr -s ' ' | cut -d ' ' -f 4 | rev | grep -vf "$LOCK_PATH" | while read -r id; do $WINGET upgrade --id "$id"; done;;
    *) $WINGET upgrade "$@";;
  esac
}

case $1 in
  upgrade) shift; upgrade "$@";;
  *) $WINGET "$@";;
esac

exit 0