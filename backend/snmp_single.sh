#!/bin/bash

echo "Content-Type: application/json"
echo ""

# Hae IP QUERY_STRINGistä
IP=$(echo "$QUERY_STRING" | sed 's/^ip=//')

DATA_DIR="/home/teleste/backend/snmp_data"
FILE="$DATA_DIR/$IP.json"

mkdir -p "$DATA_DIR"

SNMP=/usr/bin/snmpget
COMM=public

# SNMP-haut
SYSNAME=$($SNMP -v2c -c "$COMM" "$IP" 1.3.6.1.2.1.1.5.0 2>/dev/null \
  | sed 's/.*STRING: //;s/"//g')

SYSDESCR=$($SNMP -v2c -c "$COMM" "$IP" 1.3.6.1.2.1.1.1.0 2>/dev/null \
  | sed 's/.*STRING: //;s/"//g')

SYSUPTIME=$($SNMP -v2c -c "$COMM" "$IP" 1.3.6.1.2.1.1.3.0 2>/dev/null \
  | sed 's/.*Timeticks: //')

# Aikaleimat
UPDATED_ISO=$(date -Iseconds)
UPDATED_FI=$(TZ=Europe/Helsinki date '+%Y-%m-%d %H:%M:%S')

# JSON-rakenne
JSON=$(cat <<EOF
{
  "ip": "$IP",
  "sysName": "$SYSNAME",
  "sysDescr": "$SYSDESCR",
  "sysUpTime": "$SYSUPTIME",
  "updated": "$UPDATED_ISO",
  "updated_fi": "$UPDATED_FI"
}
EOF
)

# Tallenna tiedostoon ja tulosta vastauksena
echo "$JSON" > "$FILE"
echo "$JSON"

