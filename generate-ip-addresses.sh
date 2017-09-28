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

echo "Detecting current network settings..."

device_detail="$(ifconfig \
    | grep 'inet.*broadcast.*255$' -m 1 -B 10)"
dns_server="$(netstat -rn \
    | grep -i 'default' -m 1 \
    | sed 's/^[^0-9]+\([0-9.]+\).*/\1/')"

current_network_device="$(echo "$device_detail" \
    | tail -r \
    | grep -i '^[a-z0-9]\+:' -m 1 \
    | sed 's/:.*//')"
device_detail="$(echo "$device_detail" \
    | tail -n1)"
ip_subnet_mask="$(echo $device_detail \
    | sed 's/^.*mask \([^ ]*\).*$/\1/')"
ip_subnet_mask_prefix="$(echo $device_detail \
    | sed 's/^.*\([0-9]*\.[0-9]*\.[0-9]*\).255$/\1/')"
ip_address="$(echo $device_detail \
    | sed 's/^[^0-9]*\([0-9.]*\).*$/\1/')"

if [[ $(echo "$ip_subnet_mask" | grep -c '^0x') ]]; then
    m=""
    ip_subnet_mask=${ip_subnet_mask:2}
    for i in {0..3}; do
        m="$m$((16#${ip_subnet_mask:$(($i*2)):2}))."
    done
    ip_subnet_mask="$m"
fi

while [ 1 ]; do
    echo "\n1) Active network device:\t$current_network_device"
    echo "2) IPv4 Address:\t\t$ip_address"
    echo "3) Subnet Mask:\t\t$ip_subnet_mask"
    echo "4) Subnet Prefix:\t\t$ip_subnet_mask_prefix"
    echo "5) DNS Server/Router:\t\t$dns_server"

    if [[ $(echo "\nAre all of these values correct? (default yes)" \
         && read resp \
         && echo $resp | grep -ic '^n' ) ]]; then
        break
    fi

    sel=0
    while [[ $(echo "$sel" | grep -c '^[1-5]$') -le 0 ]]; then
        echo "Enter the number of the value you would like to change:"
        read sel
    fi

    echo "Enter the correct value for this item:"
    read val

    case $sel
        1) current_network_device="$val";;
        2) ip_address="$val";;
        3) ip_subnet_mask="$val";;
        4) ip_subnet_mask_prefix="$val";;
        5) dns_server="$val";;
    esac
done

echo "\nHow many IP addresses would you like to create?"
read num

while [[ $(echo $num | grep -c "^[0-9]\+$") -le 0 ]]; do
    echo "Please enter a number:"
    read num
done

addr_file="generated-ip-addresses-$(date '+%Y%m%d-%H%M%S').csv"

echo "\nCreating IP addresses..."
i=1
count=0
while [[ $count -le $num || $i -le 255 ]]; do
    addr="$ip_subnet_mask_prefix.$i"
    ping $addr -o -t 1 > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        ifconfig $current_network_device alias $addr $ip_subnet_mask
        echo "$addr" >> "$addr_file"
    fi
    let i=$i+1
done

echo "\nAddress generation complete!\nAddresses created in: $addr_file"

echo "\nUse of these addresses requires you to disable DHCP for your network connection."
echo "If you have not already done so, configure your current connection to have a manually assigned IP address, subnet mask, and DNS server."
