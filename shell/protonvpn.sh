#!/bin/sh

# Basic script to handle ProtonVPN in CLI
# Requires wg-quick and natpmpc
# Also relies on proper wireguard config

GATEWAY="10.2.0.1"
MAP_LIFETIME=60

# Basic logger
log() {
  printf "[%s] %s: %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2"
}

# Maps port for the specified protocol
map_proto() {
  proto="$1"
  output=$(timeout 5 natpmpc -a 1 0 "$proto" "$MAP_LIFETIME" -g "$GATEWAY" 2>&1)
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

# Map ports for both UDP and TCP and keep them mapped
map() {
  while true; do
    map_proto udp || break
    map_proto tcp || break
    sleep 45
  done
}

# Disconnects VPN
disconnect() {
  wg-quick down ProtonVPN
  wg-quick down ProtonVPN-CH
}

# Connects to the specified region
connect() {
  case "$1" in
    fr) disconnect; sleep 1; wg-quick up ProtonVPN;;
    ch) disconnect; sleep 1; wg-quick up ProtonVPN-CH;;
    *) log "ERROR" "Bad region selected"; exit 1
  esac
}

print_usage() {
  echo "Usage: $0 {map|connect <region>|disconnect}"
  echo "Regions: fr, ch"
}

# Args handling
case "$1" in
  map) map;;
  connect) connect "$2";;
  disconnect) disconnect;;
  *) print_usage; exit 1;;
esac