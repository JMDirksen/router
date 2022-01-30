#!/bin/bash

if [ $EUID -ne 0 ]; then echo "Please run as root"; exit 1; fi
cd "$(dirname "$0")"

./general.sh
./network.sh
./firewall.sh
./dhcp.sh
./dns.sh
