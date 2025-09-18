#!/bin/sh

# Simple script to map ports using NAT-PMP and keep them alive.
# Requires natpmpc (from libnatpmp package).

GATEWAY="10.2.0.1"
LIFETIME=60

log() {
  printf "[%s] %s: %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2"
}

map() {
  proto="$1"
  output=$(timeout 5 natpmpc -a 1 0 "$proto" "$LIFETIME" -g "$GATEWAY" 2>&1)
  status=$?
  if echo "$output" | grep -q "Mapped"; then
    log "INFO" "$(echo "$output" | grep "Mapped")"
  else
    if [ $status -eq 124 ]; then
      log "ERROR" "mapping $proto port: command timed out"
    else
      log "ERROR" "mapping $proto port: $output"
    fi
    return 1
  fi
}

while true; do
  map udp || break
  map tcp || break
  sleep 45
done

exit 0