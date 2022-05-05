#!/bin/sh
# shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common.sh"

# Wrapper script for update-java-alternatives

log "INFO" "using script wrapper for update-java-alternatives.\n"

ALTERNATIVES="$(update-java-alternatives -l | nl -w 1 -s '. ')"
printf "Available alternatives:\n%s\n" "$ALTERNATIVES"

printf "\nChoice: "
read -r ANUM
ALT=$(echo "$ALTERNATIVES" | grep -E "^$ANUM\." | cut -d ' ' -f 2)

sudo update-java-alternatives -s "$ALT"

printf "\nDon't forget to make sure JAVA_HOME is refreshed.\n"

exit 0