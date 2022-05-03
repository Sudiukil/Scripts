#!/bin/sh

# Always start from the projects directory
! [ -d "$PROJECTS_DIR" ] && echo 'ERROR: $PROJECTS_DIR is undefined (or not a dir).' && exit 1
cd $PROJECTS_DIR

usage() {
  echo "dev.sh - open a project in Visual Studio Code from a WSL shell.\n"
  echo "Usage: dev.sh <project_name>"
  echo "Options:"
  echo "\t-l list known projects names"
  echo "\t-h print this"
}

parse_args() {
  case $1 in
    '') usage; exit 1;;
    -h) usage; exit 0;;
    -l) ls -1; exit 0;;
  esac
}

parse_args $*
PROJECT_NAME="$1"
PROJECT_PATH="$PROJECTS_DIR/$1/"
WORKSPACE_PATH=$(find $PROJECT_PATH -name "*.code-workspace")

[ -z "$WORKSPACE_PATH" ] && WORKSPACE_PATH=$PROJECT_PATH

nohup code --remote wsl+Ubuntu "$WORKSPACE_PATH" > "/tmp/devsh_$PROJECT_NAME.log" 2>&1 &

exit 0