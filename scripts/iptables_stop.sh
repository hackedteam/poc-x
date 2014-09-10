#!/bin/bash
echo "0" > /proc/sys/net/ipv4/ip_forward
iptables -D FORWARD -i eth0 -o eth0:1 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -D FORWARD -i eth0:1 -o eth0 -j ACCEPT
iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -D PREROUTING -i eth0 -p tcp -d 38.229.72.14 -j RETURN
iptables -t nat -D PREROUTING -i eth0 -p tcp -d 38.229.72.16 -j RETURN
iptables -t nat -D PREROUTING -i eth0 -p tcp -d 154.35.132.70 -j RETURN
iptables -t nat -D PREROUTING -i eth0 -p tcp -d 82.195.75.101 -j RETURN
iptables -t nat -D PREROUTING -i eth0 -p tcp -d 86.59.30.40 -j RETURN
iptables -t nat -D PREROUTING -i eth0 -p tcp -d 93.95.227.222 -j RETURN