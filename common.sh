#!/bin/sh

# Log error, warning and infos
# Params
# 1. log level (ERROR, WARN or INFO)
# 2. log message (string)
# 3. [optional] return code (integer)
log() {
  [ -z "$1" ] || [ -z "$2" ] && echo "FATAL: log error" && exit 1
  echo "$1: $2"

  [ -n "$3" ] && exit "$3"
  case $1 in
    "WARN") exit 1;;
    "ERROR") exit 2;;
  esac
}