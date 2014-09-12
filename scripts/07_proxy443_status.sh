#!/bin/bash
iptables -t nat -nw -L PREROUTING | grep "443 redir"
