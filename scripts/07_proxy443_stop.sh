#!/bin/bash
iptables -t nat -D PREROUTING -i eth1 -p tcp --dport 443 -j REDIRECT --to-port 8080
iptables -D FORWARD -p tcp --dport 443 -j REJECT --reject-with tcp-reset