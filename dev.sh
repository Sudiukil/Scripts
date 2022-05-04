#!/bin/sh

# Always start from the projects directory (and make it exists/is defined)
! [ -d "$PROJECTS_DIR" ] && echo 'ERROR: $PROJECTS_DIR is undefined (or not a dir).' && exit 1
cd "$PROJECTS_DIR"

# Check if Code is available
! [ -x "$(which code)" ] && echo "ERROR: code binary isn't available." && exit 1

# Prints usage for this script
usage() {
  echo "dev.sh - open a project in Visual Studio Code from a WSL shell.\n"
  echo "Usage: dev.sh <project_name>"
  echo "Options:"
  echo "\t-l list known projects names"
  echo "\t-h print this"
}

# Opens the specified project in VSCode
# Params:
# - project name
main() {
  PROJECT_NAME="$1"
  PROJECT_PATH="$PROJECTS_DIR/$1/"
  WORKSPACE_PATH=$(find "$PROJECT_PATH" -name "*.code-workspace" 2> /dev/null)

  # Workspace path validation
  if [ -z "$WORKSPACE_PATH" ]; then
    WORKSPACE_PATH="$PROJECT_PATH"
    ! [ -d "$WORKSPACE_PATH" ] && echo "ERROR: '$(basename $WORKSPACE_PATH)' isn't a valid project name." && exit 1
  fi

  # Start a remote session for the workspace on VSCode, using the current WSL distro
  nohup code -n --remote "wsl+$WSL_DISTRO_NAME" "$WORKSPACE_PATH" > "/tmp/devsh_$PROJECT_NAME.log" 2>&1 &
}

# Creates a new project from a Git URL and open it
# Params :
# - git repo URL
new() {
  GIT_URL="$1"
  PROJECT_NAME=$(basename "$GIT_URL" .git)
  git clone "$GIT_URL"
  main "$PROJECT_NAME"
}

# Parse CLI args
parse_args() {
  case $1 in
    '') usage; exit 1;;
    -h) usage; exit 0;;
    -l) ls -1; exit 0;;
    -n) new "$2"; exit 0;;
    *) main "$1"; exit 0;;
  esac
}

# Parse args and look for the actual VSCode workspace
parse_args "$@"

exit 0
