#!/bin/sh

# Basic script to handle ProtonVPN in CLI
# Requires wg-quick, natpmpc and pcregrep
# Also relies on proper wireguard config

# Utility lib
# shellcheck disable=SC1091
. "$HOME/.scripts/shell/utils.sh"

# Constants
GATEWAY="10.2.0.1"
IP="10.2.0.2"
MAP_LIFETIME=60
UFW_RULE_BASE="allow in on ProtonVPN from any to $IP port"

# Manages UFW rules for the mapped port
ufw_allow_map_port() {
  port="$1"

  # Delete previously opened ports
  existing_ports=$(sudo ufw status | grep "ProtonVPN" | cut -d ' ' -f 2)
  if [ -n "$existing_ports" ]; then
    echo "$existing_ports" | while read -r i
    do
      ufw_out=$(echo "$UFW_RULE_BASE $i" | xargs sudo ufw delete)
      if [ "$ufw_out" != "Rule deleted" ]; then
        log "ERROR" "Failed to remove UFW rule for port $i: $ufw_out"
      else
        log "INFO" "Removed old UFW rule for port $i"
      fi
    done
  fi

  # Open the port
  ufw_out=$(echo "$UFW_RULE_BASE $port" | xargs sudo ufw)
  if [ "$ufw_out" != "Rule added" ]; then
    log "ERROR" "Failed to add UFW rule for port $port: $ufw_out"
  else
    log "INFO" "Allowed port $port through UFW"
  fi
}

# Maps port for the specified protocol
map_proto() {
  proto="$1"
  output=$(timeout 5 natpmpc -a 1 0 "$proto" "$MAP_LIFETIME" -g "$GATEWAY" 2>&1)
  map_info=$(echo "$output" | grep "Mapped")
  status=$?
  if [ -n "$map_info" ]; then
    log "INFO" "$map_info"
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
  port_mapped=0
  while true; do
    map_proto udp || break
    log_line=$(map_proto tcp) || break # Hijack the log line to get the port number
    port=$(echo "$log_line" | pcregrep -o2 "^.+(port ([0-9]{5})).+$")
    printf "%s\n" "$log_line" # Reprint the hijacked log line

    # Only update UFW once per execution, since the port should remain the same for the duration of the mapping
    if [ "$port_mapped" -eq 0 ]; then
      ufw_allow_map_port "$port"
      port_mapped=1
      echo "$port" | wl-copy # Also copy port to clipboard for convenience
      log "INFO" "Port $port copied to clipboard"
    fi
    
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

# Main script

case "$1" in
  "map")
    map;;
  "connect")
    connect "$2";;
  "disconnect")
    disconnect;;
  "h"|"help"|"-h"|"--help")
    print_usage;;
  *)
    print_usage
    exit 1;;
esac

exit 0
