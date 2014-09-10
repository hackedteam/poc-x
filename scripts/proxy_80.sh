#!/bin/bash
iptables -t nat -A PREROUTING -i eth0 -p tcp ! -d 10.0.0.1 --dport 80 -j REDIRECT --to-port 8080
