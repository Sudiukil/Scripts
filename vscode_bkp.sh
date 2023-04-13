#!/bin/sh
# shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common.sh"

# Backup script for VSCode projects config

BACKUP_DIR="vscode_backups"

[ -z "$PROJECTS_DIR" ] && log "ERROR" "Couldn't find \$PROJECTS_DIR"

mkdir "$BACKUP_DIR"
cd "$BACKUP_DIR" || exit 1

find "$PROJECTS_DIR" -maxdepth 2 -type d -name ".vscode" | while read -r path; do
  name="$(echo "$path" | rev | cut -d '/' -f 2 | rev)"
  zip -r "$name.zip" "$path"
done

exit 0