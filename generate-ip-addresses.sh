#!/bin/sh
#
# This script will generate a list of IP addresses on the current network connection
# which may be used from this machine.
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

echo "\nHow many IP addresses would you like to create?"
read num

while [[ $(echo $num | grep -c "^[0-9]\+$") -le 0 || $num -eq 0 ]]; do
    echo "Please enter a number:"
    read num
done

addr_file="generated-ip-addresses-$(date '+%Y%m%d-%H%M%S').txt"

printf "\nCreating IP addresses..."
i=1
count=0
while [[ $count -le $num || $i -le 255 ]]; do
    printf '.'
    addr="$ips_subnet_mask_prefix.$i"
    ping $addr -o -t 1 > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        ifconfig $ips_current_device alias $addr $ips_subnet_mask
        echo "$addr" >> "$addr_file"
        let count=$count+1
    fi
    let i=$i+1
done

echo "\n\nAddress generation complete!\nAddresses created in: $addr_file"

echo "\nUse of these addresses requires you to disable DHCP for your network connection."
echo "If you have not already done so, configure your current connection to have a manually assigned IP address, subnet mask, and DNS server."
