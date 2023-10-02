#!/bin/sh

# Global lib/util script
# Can be sourced in a shell or other scripts

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