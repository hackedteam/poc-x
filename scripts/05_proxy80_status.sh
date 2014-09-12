#!/bin/bash
iptables -t nat -nw -L PREROUTING | grep "80 redir"
