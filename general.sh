#!/bin/bash

if [ $EUID -ne 0 ]; then echo "Please run as root"; exit 1; fi
cd "$(dirname "$0")"

echo 1 > /proc/sys/net/ipv4/ip_forward

# Drop ICMP echo-request messages sent to broadcast or multicast addresses
#echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# Drop source routed packets
#echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route

# Enable TCP SYN cookie protection from SYN floods
#echo 1 > /proc/sys/net/ipv4/tcp_syncookies

# Don't accept ICMP redirect messages
echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects

# Don't send ICMP redirect messages
echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects

# Enable source address spoofing protection
echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter

# Log packets with impossible source addresses
echo 1 > /proc/sys/net/ipv4/conf/all/log_martians
