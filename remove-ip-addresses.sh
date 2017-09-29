#!/bin/sh
#
# This script will remove the selected generated IP addresses.
#
# Limitations:
#    Due to the OS specific nature of ifconfig, this script presently only supports MAC
#    This script must been run with root permissions
#

if [[ $EUID -ne 0 ]]; then
    echo "Insufficient access!\nThis script must be run as root"
    exit 1
fi

. "$(dirname "$0")/detect-network-settings.sh"

echo "\nIP Address source options:"
echo "1) Detect all current IP addresses"
eval files=($(ls "$(dirname "$0")"/generated-ip-addresses-*.txt 2>/dev/null))
i=0
while [[ $i -lt ${#files[@]} ]]; do
    echo "$(($i+2))) $(basename ${files[$i]})"
    let i=$i+1
done

choices="1"
if [[ $i -gt 0 ]]; then
    choices="[1-9]"
    if [[ $i -lt 8 ]]; then
        choices="[1-$((${#files[@]}+1))]"
    fi
fi
echo ''

sel=0
while [[ $(echo "$sel" | grep -c "^$choices") -le 0 || $sel -gt $((${#files[@]}+1)) ]]; do
    echo "Enter the number of the source you would like to use for value you would like to change:"
    read sel
done

printf "\nRemoving addresses..."
([[ $sel -eq 1 ]] \
    && ifconfig | grep -i 'inet.*broadcast' | sed 's/.* \([0-9.]*\) .*/\1/' \
    || cat "${files[$(($sel-2))]}") \
| while read addr; do
    printf '.'
    ifconfig $ips_current_device delete $addr
done

echo "\n\nAddress removal complete!"

echo "\nYou will now need to enable DHCP for your network connection."
