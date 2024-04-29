#!/usr/bin/env bash
IP=$(curl -s ifconfig.me)
echo "Hi this is the second page and this reply is coming from $IP" > /home/ubuntu/second.html
python3 -m http.server 8000 --directory /home/ubuntu/ &