#!/bin/bash

if [ $EUID -ne 0 ]; then echo "Please run as root"; exit 1; fi
cd "$(dirname "$0")"

. config.sh

if [ ! -f /etc/bind/rndc.key ]
then
  rndc-confgen -a -b 512
  chmod 640 /etc/bind/rndc.key
  ln -s -t /etc/dhcp /etc/bind/rndc.key
fi

cat <<EOT > /etc/bind/named.conf.options
options {
  directory "/var/cache/bind";
  query-source address * port *;
  #forwarders {
  #  1.2.3.4;
  #  1.2.3.5;
  #}
  dnssec-validation auto;
  auth-nxdomain no;
  listen-on-v6 { none; }; # You can edit this if you want IPv6 DNS services
  listen-on { 127.0.0.1; $router_ip; };
  allow-transfer { none; }; # Used if you want multiple DNS servers
  allow-recursion { 127.0.0.0/8; $subnet$router_ip_cidr; }; # Specifies the LAN can recursively ask
  version none; # Hide version number in replies
};
EOT

cat <<EOT > /etc/bind/named.conf.local
include "/etc/bind/rndc.key";

controls {
  inet 127.0.0.1 port 953 allow {
    127.0.0.1;
    $router_ip;
  } keys { "rndc-key"; };
};

zone "$domainname" {
  type master;
  file "/etc/bind/zones/$domainname";
  allow-update { key rndc-key; };
};
zone "168.192.in-addr.arpa" {
  type master;
  notify no;
  file "/etc/bind/zones/168.192.in-addr.arpa";
  allow-update { key rndc-key; };
};
EOT

service named restart
