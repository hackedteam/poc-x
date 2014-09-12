#!/bin/bash
iptables -nvw -t nat -L | grep MASQUERADE