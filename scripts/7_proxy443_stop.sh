#!/bin/bash
iptables -t nat -D PREROUTING -i eth1 -p tcp --dport 443 -j REDIRECT --to-port 8080
