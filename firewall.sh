#!/bin/bash

if [ $EUID -ne 0 ]; then echo "Please run as root"; exit 1; fi
cd "$(dirname "$0")"

. config.sh

# Policy
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Flush rules
iptables -F; iptables -t nat -F; iptables -t mangle -F

# NAT
iptables -t nat -A POSTROUTING -o $int_wan -j MASQUERADE

# Allow established/related
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# Open ports
iptables -A INPUT -p tcp --dport 22 -j ACCEPT              # SSH
iptables -A INPUT -i $int_lan -p tcp --dport 53 -j ACCEPT  # DNS
iptables -A INPUT -i $int_lan -p udp --dport 67 -j ACCEPT  # DHCP

# Allow forwarding
iptables -A FORWARD -i $int_wan -o $int_lan -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $int_lan -o $int_wan -j ACCEPT

# Port forwarding
iptables -t nat -A PREROUTING -p tcp -i $int_wan --dport 123 -j DNAT --to-destination 192.168.11.11:456
iptables -A FORWARD -p tcp -d 192.168.11.11 --dport 456 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# Logging
iptables -A FORWARD -j LOG --log-prefix='[firewall] '
iptables -A INPUT -j LOG --log-prefix='[firewall] '
