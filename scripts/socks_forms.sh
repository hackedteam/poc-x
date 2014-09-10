#!/bin/bash
ngrep -W byline -t '^(GET|POST) ' 'tcp and port 9150' >> ./data/socks_forms.txt
