# Overview
The purposes of these scripts are to generate additional IP addresses on a local machine. These IP addresses can be used for spoofing multiple hosts for tasks like performance load testing.

*Due to the OS specific nature of ifconfig, which is used by these scripts, presently only MAC OS is supported*

Note that usage of this script will disable DHCP on your active network connection. You may wish to re-enable this after use of these IP addresses is complete.

# Usage
`sudo ./generate-ip-addresses.sh` : Run the IP Address generation wizard
