#!/bin/bash
#title: Socks Sniffing
ngrep -d eth1 -W byline -t '^(GET|POST) ' 'tcp and port 9150' >> ./data/socks_forms.txt &
ngrep -d eth1 -W byline -t '^(GET|POST) ' 'tcp and port 9150' >> ./data/socks_urls.txt &
echo "Sniffing started..." >> ./data/socks_forms.txt
echo "Sniffing started..." >> ./data/socks_urls.txt