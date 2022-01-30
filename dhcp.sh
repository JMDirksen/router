#!/bin/bash

if [ $EUID -ne 0 ]; then echo "Please run as root"; exit 1; fi
cd "$(dirname "$0")"

. config.sh

cat <<EOT > /etc/default/isc-dhcp-server
INTERFACESv4="$int_lan"
EOT

cat <<EOT > /etc/dhcp/dhcpd.conf
authoritative;
subnet $subnet netmask $netmask {
  range $range;
  option domain-name-servers $router_ip;
  option domain-name "$domainname";
  option subnet-mask $netmask;
  option routers $router_ip;
  option broadcast-address $broadcast;
  default-lease-time 600;
  max-lease-time 7200;
}
EOT

service isc-dhcp-server restart
