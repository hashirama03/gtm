#!/bin/bash

## Copyright ©UDPTeam

## Discord: https://discord.gg/civ3

## Script to keep-alive your DNSTT server domain record query from target resolver/local dns server

## Run this script excluded to your VPN tunnel (split vpn tunneling mode)

## run command: ./globe-sukona.sh l

## Your DNSTT Nameserver & your Domain `A` Record

NS1='priv.ns1.jkimhost.com'
NS2='priv.ns2.jkimhost.com'
NS3='priv.ns3.jkimhost.com'
NS4='priv.ns4.jkimhost.com'
NS5='priv.ns5.jkimhost.com'
A='jkimhost.com'

## Repeat dig cmd loop time (seconds) (positive integer only)

LOOP_DELAY=5

## Add your DNS here

declare -a HOSTS=('124.6.181.12')

## Linux' dig command executable filepath

## Select value: "CUSTOM|C" or "DEFAULT|D"

DIG_EXEC="DEFAULT"

## if set to CUSTOM, enter your custom dig executable path here

CUSTOM_DIG='/data/data/com.termux/files/home/go/bin/fastdig'

VER=0.1

case "${DIG_EXEC}" in
DEFAULT|D)
    _DIG="$(command -v dig)"
    ;;
CUSTOM|C)
    _DIG="${CUSTOM_DIG}"
    ;;
esac

if [ ! "$_DIG" ]; then
    printf "Dig command failed to run, please install dig (dnsutils) or check DIG_EXEC & CUSTOM_DIG variables inside $( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/$(basename "$0") file."
    exit 1
fi

endscript() {
    unset NS1 NS2 NS3 NS4 NS5 A LOOP_DELAY HOSTS _DIG DIG_EXEC CUSTOM_DIG T R M
    exit 1
}

trap endscript 2 15

check() {
    for ((i=0; i<"${#HOSTS[*]}"; i++)); do
        for R in "${A}" "${NS1}" "${NS2}" "${NS3}" "${NS4}" "${NS5}" "${NS6}" "${NS7}" "${NS8}" "${NS9}" "${NS10}" "${NS11}" "${NS12}" "${NS13}" "${NS14}" "${NS15}" "${NS16}" "${NS17}" "${NS18}" "${NS19}" "${NS20}" "${NS21}" "${NS22}" "${NS23}" "${NS24}"; do
            T="${HOSTS[$i]}"
            if [ -z "$(timeout -k 3 3 ${_DIG} @${T} ${R})" ]; then
                M=31
            else
                M=32
            fi
            echo -e "\1;${M}m R:${R} D:${T}\0m"
            unset T R M
        done
    done
}

echo "DNSTT Keep-Alive script <Discord @civ3>"
echo -e "DNS List: \1;34m${HOSTS[*]}\0m"
echo "CTRL + C to close script"

if [ "${LOOP_DELAY}" -eq 1 ]; then
    let "LOOP_DELAY++"
fi

case "${@}" in
loop|l)
    echo "Script loop: ${LOOP_DELAY} seconds"
    while true; do
        check
        echo '.--. .-.. . .- ... .     .-- .- .. -'
        sleep ${LOOP_DELAY}
    done
    ;;
*)
    check
    ;;
esac

exit 0
