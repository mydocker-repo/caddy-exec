#!/bin/sh
HOST="$1"
UUID=$(echo "$2" | sed 's|^/\|.html$||g')

# 改这里就行
WS_PATH="/vmessws"
NAME="Alpine节点"
FP="chrome"

JSON='{"v":"2","ps":"'"$NAME $HOST"'","add":"'"$HOST"'","port":"443","id":"'"$UUID"'","aid":0,"scy":"auto","net":"ws","type":"none","host":"'"$HOST"'","path":"'"$WS_PATH"'","tls":"tls","sni":"'"$HOST"'","alpn":"h2,http/1.1","fp":"'"$FP"'"}'

echo -n "$JSON" | openssl base64 -A | tr '+/' '-_' | tr -d '=' | sed 's/^/vmess:\/\//'
