#!/bin/sh

# This scripts manages battery charging behavior
# Requires pcregrep

# Utility lib
# shellcheck disable=SC1091
. "$HOME/.scripts/shell/utils.sh"

# Path to the file controlling the charging behavior
BAT_PATH="/sys/class/power_supply/BAT0/charge_behaviour"

# Prints script usage
print_usage() {
  echo "This scripts sets battery charging behavior"
  echo "Usage: $(script_name) [a(uto)|i(nhibit)|t(oggle)]"
}

# Get the currently set charging behavior
get_current() {
  sudo cat /sys/class/power_supply/BAT0/charge_behaviour | pcregrep -o1 "\[(.+)\]"
}

# Sets charging behavior to auto (charges depending on start/end percentages not covered by this script)
set_auto() {
  echo "auto" | sudo tee $BAT_PATH > /dev/null || exit 1
  msg="Battery charging behavior set to '$(get_current)'"
  log INFO "$msg"
  notify "$msg"
}

# Sets charging behavior to inhibit-charge
set_inhibit() {
  echo "inhibit-charge" | sudo tee $BAT_PATH > /dev/null || exit 1
  msg="Battery charging behavior set to '$(get_current)'"
  log INFO "$msg"
  notify "$msg"
}

# Toggles the charging behavior between auto and inhibit-charge depending on the current behavior
toggle() {
  current_mode=$(get_current)

  case "$current_mode" in
    "auto")
      set_inhibit;;
    "inhibit-charge")
      set_auto;;
    *)
      log ERROR "Current mode ($current_mode) is not recognized, aborting..."
      exit 1;;
  esac
}

# Main script

case "$1" in
  "auto"|"a")
    set_auto;;
  "inhibit"|"i")
    set_inhibit;;
  "toggle"|"t")
    toggle;;
  "h"|"help"|"-h"|"--help")
    print_usage;;
  *)
    print_usage
    exit 1;;
esac

exit 0
