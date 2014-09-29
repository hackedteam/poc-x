#!/bin/bash
#title: Iptables Routing and NAT
echo "1" > /proc/sys/net/ipv4/ip_forward
iptables -A FORWARD -i eth1 -p tcp -d 38.229.72.14 -j ACCEPT
iptables -A FORWARD -i eth1 -p tcp -d 38.229.72.16 -j ACCEPT
iptables -A FORWARD -i eth1 -p tcp -d 154.35.132.70 -j ACCEPT
iptables -A FORWARD -i eth1 -p tcp -d 82.195.75.101 -j ACCEPT
iptables -A FORWARD -i eth1 -p tcp -d 86.59.30.40 -j ACCEPT
iptables -A FORWARD -i eth1 -p tcp -d 93.95.227.222 -j ACCEPT

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A PREROUTING -i eth1 -p tcp -d 38.229.72.14 -j RETURN
iptables -t nat -A PREROUTING -i eth1 -p tcp -d 38.229.72.16 -j RETURN
iptables -t nat -A PREROUTING -i eth1 -p tcp -d 154.35.132.70 -j RETURN
iptables -t nat -A PREROUTING -i eth1 -p tcp -d 82.195.75.101 -j RETURN
iptables -t nat -A PREROUTING -i eth1 -p tcp -d 86.59.30.40 -j RETURN
iptables -t nat -A PREROUTING -i eth1 -p tcp -d 93.95.227.222 -j RETURN