#!/usr/bin/env bash

# DNSTT Keep-Alive Script
# Copyright ©UDPTeam
# Moded by: J'Kim Jamil

# Constants
NS=('jkimdns.com' 'ismael.ns.hashi-rama.com')
A='jkimdns.com'
DEFAULT_DIG="$(command -v dig)"
CUSTOM_DIG='/data/data/com.termux/files/home/go/bin/fastdig'

# User Configurable Variables
LOOP_DELAY=5
HOSTS=('124.6.181.12' '124.6.181.20' '124.6.181.4' '124.6.181.36')
DIG_EXEC="DEFAULT" # Options: "DEFAULT" or "CUSTOM"

# Select dig executable
case "${DIG_EXEC}" in
    "CUSTOM") DIG_CMD="${CUSTOM_DIG}" ;;
    *) DIG_CMD="${DEFAULT_DIG}" ;;
esac

# Validation
if [ ! "${DIG_CMD}" ]; then
    echo "Error: dig command not found. Check DIG_EXEC and CUSTOM_DIG variables."
    exit 1
fi

if [ "${#HOSTS[@]}" -eq 0 ]; then
    echo "Error: HOSTS array is empty. Add DNS server IPs to HOSTS array."
    exit 1
fi

if ! [[ "${LOOP_DELAY}" =~ ^[0-9]+$ ]]; then
    echo "Error: LOOP_DELAY must be a positive integer."
    exit 1
fi

# Signal handling
trap cleanup INT TERM

cleanup() {
    echo "Cleaning up and exiting."
    exit 0
}

# DNS Query Function
query_dns() {
    for host in "${HOSTS[@]}"; do
        for record in "${A}" "${NS[@]}"; do
            if ! timeout -k 3 3 "${DIG_CMD}" @"${host}" "${record}" &> /dev/null; then
                echo -e "\033[1;31mFailed: ${record} at ${host}\033[0m"
            else
                echo -e "\033[1;32mSuccess: ${record} at ${host}\033[0m"
            fi
        done
    done
}

# Script Execution
echo "DNSTT Keep-Alive script"
echo -e "DNS List: \033[1;34m${HOSTS[*]}\033[0m"
echo "CTRL + C to exit script"

case "${1}" in
    loop|l)
        echo "Running in loop mode with delay: ${LOOP_DELAY} seconds"
        while true; do
            query_dns
            sleep "${LOOP_DELAY}"
        done
        ;;
    *)
        query_dns
        ;;
esac
