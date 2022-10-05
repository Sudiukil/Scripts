#!/bin/sh
# shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common.sh"

# Wrapper script for winget

# TODO: fix pin ids (e.g. pinning "Microsoft.Edge" pins more than that)
# TODO: check if `upgrade --all` is fixed (loop broke after first iteration)

# Vars
WINGET="$USERPROFILE/AppData/Local/Microsoft/WindowsApps/winget.exe"
WINGET_COMPATIBILITY="v1.3.2091"
LOCK_PATH="$HOME/.winget.lock"

# Checks
[ -x "$WINGET" ] || log "ERROR" "winget binary isn't available."
ver=$($WINGET -v)
[ "$WINGET_COMPATIBILITY" = "$ver" ] || log "WARNING" "winget version mismatch, use with caution (current: $ver, supported: $WINGET_COMPATIBILITY)."
[ -f "$LOCK_PATH" ] || log "ERROR" "Lock file not found."

# Sanitize lockfile
sed -e '/^$/d' -i "$LOCK_PATH"

# Overloads some of `winget upgrade` options to ignore pinned packages:
# - `upgrade` will not list pinned packages
# - `upgrade --all` will not upgrade pinned packages
# - individual operations (such as `upgrade --id <id>`) keep their default behavior
upgrade() {
  case $1 in
    --all) $WINGET upgrade | rev | grep "tegniw" | tr -s ' ' | cut -d ' ' -f 4 | rev | grep -vf "$LOCK_PATH" | while read -r id; do echo "" | $WINGET upgrade --id "$id"; done;;
    '') $WINGET upgrade | grep -vf "$LOCK_PATH"; echo "$(grep -c ^ "$LOCK_PATH") upgrades are ignored (pinned versions).";;
    *) $WINGET upgrade "$@";;
  esac
}

# Lists pinned packages
pin_list() {
  if ! [ -s "$LOCK_PATH" ]; then echo "No pinned packages."; return; fi
  
  list=$($WINGET list)
  
  echo "$list" | sed -e '1,2!d'
  echo "$list" | grep -f "$LOCK_PATH"
}

# Pins a package
pin_add() {
  list=$($WINGET list)
  
  if ! echo "$list" | grep -q "$1"; then log "ERROR" "$1 isn't installed (or isn't a valid package ID)."; fi
  if grep -q "^$1$" "$LOCK_PATH"; then log "WARNING" "$1 is already pinned."; return; fi

  echo "$1" >> "$LOCK_PATH"
  echo "$1 pinned to version $(echo "$list" | grep "$1" | rev | tr -s ' ' | cut -d ' ' -f 3 | rev)"
}

# Removes a package pin
pin_unpin() {
  if ! grep -q "^$1$" "$LOCK_PATH"; then log "ERROR" "$1 isn't pinned (or isn't a valid package ID)."; fi

  sed '/^'"$1"'$/d' -i "$LOCK_PATH"
  echo "Removed $1 pin."
}

# Adds a `winget pin` option to manage package pins
# Packages pins allow to lock a package to its currently installed version
pin() {
  case $1 in
    -u) shift; pin_unpin "$@";;
    '') pin_list;;
    *) pin_add "$@";;
  esac
}

# Args parser
case $1 in
  upgrade) shift; upgrade "$@";;
  pin) shift; pin "$@";;
  *) $WINGET "$@";;
esac

exit 0