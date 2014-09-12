#!/bin/bash
iptables -nv -t nat -L | grep MASQUERADE