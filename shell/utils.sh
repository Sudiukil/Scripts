#!/bin/sh

# This is a collection of utility functions

# This resolves the current script name, even through symlinks
script_name() {
  script="$0"

  while [ -L "$script" ]; do
    script=$(readlink "$script")
  done

  basename "$script"
}

# This resolves the current script directory, even through symlinks
script_dir() {
  script="$0"

  while [ -L "$script" ]; do
    script=$(readlink "$script")
  done

  cd "$(dirname "$script")" && pwd
}

# Sends a graphical notification
notify() {
  notify-send -a "$(script_name)" "$1"
}

# Logs a message to the console, with a level and a date
log() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    log ERROR "log() call missing an argument (usage: log [level] [message])"
    exit 1
  fi

  format="[%s] %s: %s\n"
  level=$(echo "$1" | tr '[:lower:]' '[:upper:]')
  datetime=$(date +'%Y-%m-%d %H:%M:%S')
  message="$2"

  if [ "$level" = "ERROR" ]; then
    # shellcheck disable=SC2059
    printf "$format" "$level" "$datetime" "$message" >&2
  else
    # shellcheck disable=SC2059
    printf "$format" "$level" "$datetime" "$message"
  fi
}
