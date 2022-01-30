#!/bin/bash

if [ $EUID -ne 0 ]; then echo "Please run as root"; exit 1; fi
cd "$(dirname "$0")"

. config.sh

cat <<EOT > /etc/netplan/99-router.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    $int_wan:
      dhcp4: yes
      dhcp4-overrides:
          use-dns: no
      nameservers:
        addresses: [$nameservers]
    $int_lan:
      dhcp4: no
      addresses: [$router_ip]
EOT

netplan apply
