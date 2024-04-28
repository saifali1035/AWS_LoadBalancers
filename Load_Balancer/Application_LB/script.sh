#!/bin/bash
IP=$(curl -s ifconfig.me)
echo "Hi this is a web page and this reply is coming from $IP" > /home/ubuntu/index.html
python3 -m http.server 8000 --directory /home/ubuntu/ &