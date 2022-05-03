#!/bin/sh

# Minimalist FIFO message queue script

MESSAGES_FILE="$HOME/.messages"

push_message() {
  [ -z "$1" ] && echo "ERROR: No message specified." && exit 1
  echo "$1" >> "$MESSAGES_FILE"
}

pop_message() {
  LAST_MESSAGE=$(head -n 1 "$MESSAGES_FILE")
  [ -z "$LAST_MESSAGE" ] && echo "WARN: No message to delete." && exit 0
  sed -i '1d' "$MESSAGES_FILE"
  echo "Deleted '$LAST_MESSAGE' from messages."
}

purge_messages() {
  truncate -s 0 "$MESSAGES_FILE"
  echo "INFO: all messages deleted."
}

list_messages() {
  cat "$MESSAGES_FILE" | sed -e 's/^/- /g'
}

cowsay_messages() {
  ! [ -x $(which cowsay) ] && echo "ERROR: cowsay unavaible." && exit 1

  case $(cat "$MESSAGES_FILE" | wc -l) in
    0) exit 0;;
    1) echo "You have one message:\n$(head -n 1 "$MESSAGES_FILE")" | cowsay -n;;
    *) echo "You have many messages:\n$(list_messages)" | cowsay -n;;
  esac
}

parse_args() {
  case $1 in
    -a) push_message "$2";;
    -d) pop_message;;
    -l) list_messages;;
    -c) cowsay_messages;;
    -D) purge_messages;;
  esac
}

touch "$MESSAGES_FILE"
parse_args "$@"

exit 0