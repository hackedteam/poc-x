#!/bin/bash
iptables -t nat -n -L PREROUTING | grep "80 redir"
