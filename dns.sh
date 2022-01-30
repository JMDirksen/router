#!/bin/bash

if [ $EUID -ne 0 ]; then echo "Please run as root"; exit 1; fi
cd "$(dirname "$0")"

. config.sh

if [ ! -f /etc/bind/rndc.key ]
then
  rndc-confgen -a -b 512
  chmod 640 /etc/bind/rndc.key
  cp /etc/bind/rndc.key /etc/dhcp/rndc.key
fi

cat <<EOT > /etc/bind/named.conf.options
options {
  directory "/var/cache/bind";
  auth-nxdomain no;
  listen-on-v6 { none; };
  listen-on { 127.0.0.1; $router_ip; };
  allow-transfer { none; };
  allow-query { 127.0.0.0/8; $subnet$router_ip_cidr; };
  allow-recursion { 127.0.0.0/8; $subnet$router_ip_cidr; };
  version none;
};
EOT

cat <<EOT > /etc/bind/named.conf.local
include "/etc/bind/rndc.key";
zone "$domainname" {
  type master;
  file "/etc/bind/$domainname.zone";
  allow-update { key rndc-key; };
};
include "/etc/bind/zones.rfc1918";
EOT

cat <<EOT > /etc/bind/$domainname.zone
\$ORIGIN $domainname.
\$TTL 86400
@ IN SOA $router_ip. root.localhost. (
2022013001  ; serial number YYMMDDNN
28800       ; Refresh
7200        ; Retry
864000      ; Expire
86400       ; Min TTL
)
NS $router_ip.
EOT

service named restart
