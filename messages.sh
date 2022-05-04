#!/bin/sh
# shellcheck disable=SC1091
. "$(dirname "$(readlink -f "$0")")/common.sh"

# Minimalist FIFO message queue script

MESSAGES_FILE="$HOME/.messages"

# Add a new message
# Params:
# 1. message (string)
push_message() {
  [ -z "$1" ] && log "ERROR" "No message specified."
  echo "$1" >> "$MESSAGES_FILE"
  echo "'$1' added to messages."
}

# Pop the oldest message
pop_message() {
  LAST_MESSAGE=$(head -n 1 "$MESSAGES_FILE")
  [ -z "$LAST_MESSAGE" ] && log "WARN" "No message to delete."
  sed -i '1d' "$MESSAGES_FILE"
  echo "'$LAST_MESSAGE' deleted from messages."
}

# Delete all messages
purge_messages() {
  while read -r m; do
    pop_message "$m"
  done < "$MESSAGES_FILE"
}

# Show all messages
list_messages() {
  sed -e 's/^/\* /g' "$MESSAGES_FILE"
}

# Show all messages with Cowsay
cowsay_messages() {
  ! [ -x "$(which cowsay)" ] && echo "ERROR: cowsay unavaible." && exit 1

  case $(wc -l "$MESSAGES_FILE" | cut -d ' ' -f 1) in
    0) exit 0;;
    1) printf "You have a message:\n%s" "$(cat "$MESSAGES_FILE")" | cowsay -n;;
    *) printf "You have messages:\n%s" "$(list_messages)" | cowsay -n;;
  esac
}

# Open messages in $EDITOR
edit_messages() {
  $EDITOR "$MESSAGES_FILE"
}

# Display usage help
usage() {
  printf "messages.sh: minimalist FIFO message queue.\n
  \rUsage:
  -a <message> add a new message
  -d delete the oldest message
  -l show all messages
  -c display all messages with Cowsay
  -D purge messages (deletes all messages WITHOUT confirmation)
  -e open the messages file in editor
  -h print this\n"
}

parse_args() {
  case $1 in
    -a) push_message "$2";;
    -d) pop_message;;
    -l) list_messages;;
    -c) cowsay_messages;;
    -D) purge_messages;;
    -e) edit_messages;;
    *) usage;;
  esac
}

touch "$MESSAGES_FILE"
parse_args "$@"

exit 0