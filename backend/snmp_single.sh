#!/bin/bash
echo "Content-Type: application/json"
echo ""

IP=$(echo "$QUERY_STRING" | sed 's/^ip=//')

DATA_DIR="/home/teleste/backend/snmp_data"
FILE="$DATA_DIR/$IP.json"

mkdir -p "$DATA_DIR"

SNMP=/usr/bin/snmpget
COMM=public

SYSNAME=$($SNMP -v2c -c "$COMM" "$IP" 1.3.6.1.2.1.1.5.0 2>/dev/null | sed 's/.*STRING: //;s/"//g')
SYSDESCR=$($SNMP -v2c -c "$COMM" "$IP" 1.3.6.1.2.1.1.1.0 2>/dev/null | sed 's/.*STRING: //;s/"//g')
SYSUPTIME=$($SNMP -v2c -c "$COMM" "$IP" 1.3.6.1.2.1.1.3.0 2>/dev/null | sed 's/.*Timeticks: //')

JSON=$(cat <<EOF
{
  "ip": "$IP",
  "sysName": "$SYSNAME",
  "sysDescr": "$SYSDESCR",
  "sysUpTime": "$SYSUPTIME",
  "updated": "$(date -Iseconds)"
}
EOF
)

echo "$JSON" > "$FILE"

echo "$JSON"
