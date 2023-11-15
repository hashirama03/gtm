#!/bin/bash

# Copyright ©UDPTeam
# Modified by: J'Kim Jamil
# Script to keep-alive your DNSTT server domain record query from target resolver/local DNS server
# Run this script excluded to your VPN tunnel (split VPN tunneling mode)
# Run command: ./config.sh l
# Your DNSTT Nameserver & your Domain 'A' Record

NS=('ismael.ns.hashi-rama.com')
A='jkimdns.com'
LOOP_DELAY=5  # Repeat dig cmd loop time in seconds (positive integer only)
HOSTS=('124.6.181.12' '124.6.181.20' '124.6.181.4' '124.6.181.36')  # Add your DNS here
DIG_EXEC="DEFAULT"  # Linux' dig command executable filepath (Choose: "CUSTOM|C" or "DEFAULT|D")
CUSTOM_DIG='/data/data/com.termux/files/home/go/bin/fastdig'  # Custom dig executable path
VER=0.1

# Determine dig command
case "${DIG_EXEC}" in
    DEFAULT|D) _DIG="$(command -v dig)" ;;
    CUSTOM|C)  _DIG="${CUSTOM_DIG}" ;;
    *) echo "Invalid DIG_EXEC value. Must be DEFAULT|D or CUSTOM|C"; exit 1 ;;
esac

if [ ! "$_DIG" ]; then
    echo "Dig command not found. Install dnsutils or check DIG_EXEC & CUSTOM_DIG variables."
    exit 1
fi

# Handle script termination
endscript() {
    trap - 2 15
    echo "Exiting script..."
    exit 0
}

trap endscript 2 15

# Check DNS records
check() {
    for host in "${HOSTS[@]}"; do
        for record in "${A}" "${NS[@]}"; do
            if [ -z "$(timeout 3 ${_DIG} @${host} ${record})" ]; then
                color=31  # Red for failure
            else
                color=32  # Green for success
            fi
            echo -e "\e[1;${color}mRecord: ${record}, DNS: ${host}\e[0m"
        done
    done
}

# Main execution
echo "DNSTT Keep-Alive script>"
echo -e "DNS List: \e[1;34m${HOSTS[*]}\e[0m"
echo "CTRL + C to exit script"

# Loop if specified
case "${1}" in
    loop|l)
        echo "Looping every ${LOOP_DELAY}s"
        while true; do
            check
            echo '.--. .-.. . .- ... .     .-- .- .. -'
            sleep "${LOOP_DELAY}"
        done
        ;;
    *)
        check
        ;;
esac

exit 0
