#!/bin/sh
# shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common.sh"

# Script to sync .vscode workspaces to an external repo for backup purposes

# Check for the projects dir
[ -d "$PROJECTS_DIR" ] || log "ERROR" "$PROJECTS_DIR does not exists."

# Git repo used to backup
BKP_REPO="$PROJECTS_DIR/vscode_workspaces/"
[ -d "$BKP_REPO" ] || log "ERROR" "$BKP_REPO does not exists."

# shellcheck disable=SC2012
ls "$PROJECTS_DIR" | while read -r name; do
  # Code workspace and backup directories
  BKP_DIR="$BKP_REPO/$name/"
  CODE_WS="$PROJECTS_DIR/$name/.vscode/"

  # Ignore project is no Code workspace is found
  [ -d "$CODE_WS" ] || continue

  # Sync Code workspace and backup dir
  [ -d "$BKP_DIR" ] || mkdir "$BKP_DIR"
  rsync -avuq --delete "$CODE_WS/" "$BKP_DIR/"
done

# Commit and push backup repo changes
cd "$BKP_REPO" || exit 1
git add -A
git commit -m "Update"
git push -q

exit 0