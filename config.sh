#!/bin/bash

# DNSTT Keep-Alive Script
# Version 0.2
# Copyright © UDPTeam
# Discord: https://discord.gg/civ3

# This script keeps your DNSTT server domain record query active.
# Exclude this script from your VPN tunnel (split VPN tunneling mode).
# Usage: ./config.sh loop

# DNSTT Nameservers and Domain 'A' Record
NAMESERVERS=(
    'us1-ns.jkimdns.com'
    'hk1-ns.jkimdns.com'
    'james.ubuntu.sardinas.cf'
    'sg1-ns.jkimdns.com'
    'sg1-dns.microsshsvr.host'
    'sg2-ns.jkimdns.com'
)
DOMAIN_RECORD='sdns01.volantdns.com'

# Loop delay time in seconds (positive integer only)
LOOP_DELAY=5

# List of DNS hosts
DNS_HOSTS=('124.6.181.12' '124.6.181.20' '124.6.181.4' '124.6.181.36')

# Dig command settings
DIG_MODE="DEFAULT"  # Options: "CUSTOM" or "DEFAULT"
CUSTOM_DIG_PATH='/data/data/com.termux/files/home/go/bin/fastdig'

# Selecting dig executable based on user preference
case "${DIG_MODE}" in
    DEFAULT)
        DIG_CMD="$(command -v dig)"
        ;;
    CUSTOM)
        DIG_CMD="${CUSTOM_DIG_PATH}"
        ;;
    *)
        echo "Invalid DIG_MODE set. Choose DEFAULT or CUSTOM."
        exit 1
        ;;
esac

# Validate dig command
if [ -z "${DIG_CMD}" ]; then
    echo "Dig command not found. Install dnsutils or set CUSTOM_DIG_PATH correctly."
    exit 1
fi

# Function to perform DNS queries
perform_dns_query() {
    local host="$1"
    local record="$2"
    local result

    result=$(timeout -k 3 3 "${DIG_CMD}" @"${host}" "${record}")
    if [ -z "${result}" ]; then
        echo -e "\e[1;31mFAIL: Record: ${record}, Host: ${host}\e[0m"
    else
        echo -e "\e[1;32mOK: Record: ${record}, Host: ${host}\e[0m"
    fi
}

# Main query loop
run_query_loop() {
    for host in "${DNS_HOSTS[@]}"; do
        for ns in "${NAMESERVERS[@]}" "${DOMAIN_RECORD}"; do
            perform_dns_query "${host}" "${ns}"
        done
    done
}

# Main script execution
echo "DNSTT Keep-Alive Script - Discord @civ3"
echo -e "DNS Hosts: \e[1;34m${DNS_HOSTS[*]}\e[0m"
echo "CTRL + C to stop the script"

# Loop delay adjustment
if [ "${LOOP_DELAY}" -le 1 ]; then
    LOOP_DELAY=2
fi

case "$1" in
    loop)
        echo "Running in loop mode with delay: ${LOOP_DELAY} seconds"
        while true; do
            run_query_loop
            echo '.--. .-.. . .- ... .     .-- .- .. -'
            sleep "${LOOP_DELAY}"
        done
        ;;
    *)
        run_query_loop
        ;;
esac

exit 0
