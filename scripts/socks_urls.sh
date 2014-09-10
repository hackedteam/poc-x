#!/bin/bash
ngrep -W byline -t '^(GET|POST) ' 'tcp and port 9150' | grep -e 'Host: .*' >> ./data/socks_urls.txt
