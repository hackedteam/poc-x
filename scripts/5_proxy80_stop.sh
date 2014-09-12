#!/bin/bash
iptables -t nat -D PREROUTING -i eth1 -p tcp ! -d 10.0.0.1 --dport 80 -j REDIRECT --to-port 8080
