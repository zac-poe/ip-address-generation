# Overview
The purposes of these scripts are to generate additional IP addresses on a local machine. These IP addresses can be used for tasks where multiple requesters are required, such as performance load testing.

Note that usage of multiple IP addresses on a single machine may require temporarily disabling any local Firewalls. These are commonly part of antivirus suites.

*Due to the OS specific nature of ifconfig, which is used by these scripts, presently only MAC OS is supported*

# Usage
`sudo ./generate-ip-addresses.sh` : Run the IP address generation wizard

`sudo ./remove-ip-addresses.sh` : Run the IP address removal wizard
