#
# when imported, this script will assign the following variables:
#     $ips_current_device
#     $ips_current_address
#     $ips_dns_server
#     $ips_subnet_mask
#     $ips_subnet_mask_prefix
#

echo "Detecting current network settings..."

device_detail="$(ifconfig \
    | grep 'inet.*broadcast.*255$' -m 1 -B -1)"
ips_dns_server="$(netstat -rn \
    | grep -i 'default' -m 1 \
    | sed 's/^[^0-9]*\([0-9.]*\).*/\1/')"

ips_current_device="$(echo "$device_detail" \
    | tail -r \
    | grep -i '^[a-z0-9]\+:' -m 1 \
    | sed 's/:.*//')"
device_detail="$(echo "$device_detail" \
    | tail -n1)"
ips_subnet_mask="$(echo $device_detail \
    | sed 's/^.*mask \([^ ]*\).*$/\1/')"
ips_subnet_mask_prefix="$(echo $device_detail \
    | sed 's/^.* \([0-9]*\.[0-9]*\.[0-9]*\)\.255$/\1/')"
ips_current_address="$(echo $device_detail \
    | sed 's/^[^0-9]*\([0-9.]*\).*$/\1/')"

if [[ $(echo "$ips_subnet_mask" | grep -c '^0x') ]]; then
    m=""
    ips_subnet_mask=${ips_subnet_mask:2}
    for i in {0..3}; do
        if [[ ${#m} -gt 0 ]]; then
            m=$m.
        fi
        m="$m$((16#${ips_subnet_mask:$(($i*2)):2}))"
    done
    ips_subnet_mask="$m"
fi

while [ 1 ]; do
    echo "\n1) Active network device: $ips_current_device"
    echo "2) IPv4 Address:          $ips_current_address"
    echo "3) Subnet Mask:           $ips_subnet_mask"
    echo "4) Subnet Prefix:         $ips_subnet_mask_prefix"
    echo "5) DNS Server/Router:     $ips_dns_server\n"

    resp=""
    while [[ $(echo "$resp" | grep -ic '^[n|y]') -le 0 ]]; do
        echo "Are all of these values correct? [y/n]"
        read resp
    done
    if [[ $(echo $resp | grep -ic '^y') -gt 0 ]]; then
        break
    fi

    sel=0
    while [[ $(echo "$sel" | grep -c '^[1-5]$') -le 0 ]]; do
        echo "Enter the number of the value you would like to change:"
        read sel
    done

    echo "Enter the correct value for this item:"
    read val

    case "$sel" in
        1) ips_current_device="$val";;
        2) ips_current_address="$val";;
        3) ips_subnet_mask="$val";;
        4) ips_subnet_mask_prefix="$val";;
        5) ips_dns_server="$val";;
    esac
done
