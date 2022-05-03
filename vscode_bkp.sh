#!/bin/sh

# Script to backup .vscode config dirs to an external location

# Make sure relevant directories exist
! [ -d "$PROJECTS_DIR" ] && echo 'ERROR: $PROJECTS_DIR is undefined (or not a dir).' && exit 1
! [ -d "./.vscode" ] && echo "ERROR: No .vscode dir found here!" && exit 1

# Ensure we only work under the projects directory, to avoid any dangerous operations on other files
check_path() {
  if ! $(echo $1 | grep "^$PROJECTS_DIR" > /dev/null); then
    echo "ERROR: $1 isn't under your projects dir ($PROJECTS_DIR), aborting."
    exit 1
  fi
}

# Target backup dir/repo
BACKUP_DIR="$PROJECTS_DIR/vscode_workspaces/"
check_path "$BACKUP_DIR"
PROJECT_NAME=$(basename $(pwd))
BACKUP_PATH="$BACKUP_DIR/$PROJECT_NAME/"
check_path "$BACKUP_PATH"

# Remove previous backup and copy data
[ -d "$BACKUP_PATH" ] && rm -r "$BACKUP_PATH"
cp -r ./.vscode "$BACKUP_PATH"

# Add new backup to versioning
cd "$BACKUP_DIR"
git add "$PROJECT_NAME"
git commit -m "Updated '$PROJECT_NAME' backup"
git push

exit 0
