#!/bin/bash
kill -9 `ps a | grep ruby | grep socks.rb | cut -f 2 -d ' '`
