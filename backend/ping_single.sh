#!/bin/bash

echo "Content-Type: application/json"
echo ""

IP=$(echo "$QUERY_STRING" | sed -n 's/^ip=//p')

if [ -z "$IP" ]; then
  echo '{"error":"ip missing"}'
  exit 1
fi

PING_OUTPUT=$(ping -c 4 -W 1 "$IP" 2>/dev/null)
STATUS=$?

if [ $STATUS -eq 0 ]; then
  LOSS=$(echo "$PING_OUTPUT" | grep -oP '\d+(?=% packet loss)')
  RTT=$(echo "$PING_OUTPUT" | grep rtt | awk -F'/' '{print $5}')
  RESULT="ok"
else
  LOSS="100"
  RTT=""
  RESULT="down"
fi

cat <<EOF
{
  "ip": "$IP",
  "status": "$RESULT",
  "packetLoss": "$LOSS",
  "rtt": "$RTT"
}
EOF
