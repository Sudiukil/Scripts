#!/bin/sh

# Log errors, warnings and infos
# Exits for anything above INFO level
# Params
# 1. log level (ERROR, WARN or INFO)
# 2. log message (string)
# 3. [optional] return code (integer)
log() {
  [ -z "$1" ] || [ -z "$2" ] && log "FATAL" "Logger error"
  echo "$1: $2"

  [ -n "$3" ] && exit "$3"
  case $1 in
    "WARN") exit 1;;
    "ERROR") exit 2;;
    "FATAL") exit 3;;
  esac
}

win_path_to_wsl() {
  [ -z "$1" ] && log "INFO" "Please provide a path to convert"

  printf '%s' "$1" | sed -e 's;\\;/;g' -e 's/://' -e 's;^.;/mnt/\L&;'
}

wsl_path_to_win() {
  [ -z "$1" ] && log "INFO" "Please provide a path to convert"

  printf '%s' "$1" | sed -e 's;/mnt/;;' -e 's/^./\U&:/' -e 's;/;\\;g'
}