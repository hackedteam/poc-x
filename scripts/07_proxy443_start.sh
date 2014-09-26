#!/bin/bash
#title: Intercept HTTPS
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 443 -j REDIRECT --to-port 8080
iptables -A FORWARD -p tcp --dport 443 -j REJECT --reject-with tcp-reset