#!/bin/sh
# shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common.sh"

# Always start from the projects directory
cd "$PROJECTS_DIR" || log "ERROR" "PROJECTS_DIR is undefined (or not a dir)."

# Check if Code is available
[ -x "$(which code)" ] || log "ERROR" "code binary isn't available."

# Creates a new project from a Git URL and open it
# Params :
# - git repo URL
new() {
  GIT_URL="$1"
  PROJECT_NAME=$(basename "$GIT_URL" .git)
  git clone "$GIT_URL"
  main "$PROJECT_NAME"
}

pick() {
  # shellcheck disable=SC2012
  PLIST=$(ls | nl -w 1 -s ' ')
  printf "Available projects:\n%s\n" "$PLIST"
  printf "Type in the project number: "
  read -r PNUM
  main "$(echo "$PLIST" | grep -E "^$PNUM " | cut -d ' ' -f 2)"
}

# Opens the specified project in VSCode
# Params:
# 1. project name (string)
main() {
  PROJECT_NAME="$1"
  PROJECT_PATH="$PROJECTS_DIR/$1/"
  WORKSPACE_PATH=$(find "$PROJECT_PATH" -name "*.code-workspace" 2> /dev/null)

  # Workspace path validation
  if [ -z "$WORKSPACE_PATH" ]; then
    WORKSPACE_PATH="$PROJECT_PATH"
    [ -d "$WORKSPACE_PATH" ] || log "ERROR" "'$(basename "$WORKSPACE_PATH")' isn't a valid project name."
  fi

  # Start a remote session for the workspace on VSCode, using the current WSL distro
  nohup code -n --remote "wsl+$WSL_DISTRO_NAME" "$WORKSPACE_PATH" > "/tmp/devsh_$PROJECT_NAME.log" 2>&1 &
}

# Prints usage for this script
usage() {
  printf "dev.sh - open a project in Visual Studio Code from a WSL shell.\n
  \rUsage: dev.sh <project_name>
  \rOptions:
  \t-l list known projects names
  \t-n <git repo URL> clone a new project and open it
  \t-p pick a project interactively
  \t-h print this\n"
}

# Parse CLI args
parse_args() {
  case $1 in
    -l) ls -1;;
    -n) new "$2";;
    -p) pick;;
    -h) usage;;
    '') usage; exit 1;;
    *) main "$1";;
  esac
}

# Parse args and look for the actual VSCode workspace
parse_args "$@"

exit 0
