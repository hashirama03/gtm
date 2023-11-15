#!/bin/bash

# Professional DNSTT Keep-Alive Script
# Copyright © UDPTeam
# Discord: https://discord.gg/civ3
# Version 1.1

# Description: This script maintains the DNS record query for a DNSTT server.
# Usage: ./globe-sukona.sh [loop]
# Use 'loop' option for continuous execution.

# DNS Nameservers and Domain 'A' Record Configuration
declare -a NAMESERVERS=(
  'ismael.ns.hashi-rama.com'
)
DOMAIN_A_RECORD='www.globe.com.ph'

# Loop delay in seconds (positive integer only)
LOOP_DELAY=5

# Target Resolver / Local DNS Servers
declare -a HOSTS=('124.6.181.12' '124.6.181.20' '124.6.181.4' '124.6.181.36')

# Dig Command Configuration
DIG_MODE="DEFAULT"  # Options: DEFAULT or CUSTOM
CUSTOM_DIG_PATH='/data/data/com.termux/files/home/go/bin/fastdig'

# Determine the dig command path
dig_command() {
  if [[ "$DIG_MODE" == "CUSTOM" ]]; then
    echo "$CUSTOM_DIG_PATH"
  else
    command -v dig
  fi
}

# Validate dig command
DIG=$(dig_command)
if [[ -z "$DIG" ]]; then
  echo "Error: dig command not found. Please install dnsutils or set the DIG_MODE."
  exit 1
fi

# Clean-up function for script termination
cleanup() {
  echo "Cleaning up and exiting."
  trap - SIGINT SIGTERM
  exit 0
}

# Register signal handlers
trap cleanup SIGINT SIGTERM

# DNS Check Function
dns_check() {
  for host in "${HOSTS[@]}"; do
    for ns in "${NAMESERVERS[@]}" "$DOMAIN_A_RECORD"; do
      if timeout -k 3 3 "$DIG" @"$host" "$ns" &> /dev/null; then
        echo -e "\033[1;32mSuccess: ${ns} from ${host}\033[0m"
      else
        echo -e "\033[1;31mFailure: ${ns} from ${host}\033[0m"
      fi
    done
  done
}

# Main Execution
echo "DNSTT Keep-Alive Script"
echo "DNS Targets: ${HOSTS[*]}"
echo "Press CTRL+C to stop."

if [[ "$1" == "loop" ]]; then
  echo "Running in loop mode. Delay: ${LOOP_DELAY} seconds."
  while true; do
    dns_check
    sleep "$LOOP_DELAY"
  done
else
  dns_check
fi

cleanup
