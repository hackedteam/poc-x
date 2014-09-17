#!/bin/bash
kill -9 `ps a | grep ruby | grep socks.rb | awk '{print $1}'`
