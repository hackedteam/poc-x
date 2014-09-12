#!/bin/bash
iptables -t nat -n -L PREROUTING | grep "443 redir"
