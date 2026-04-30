#!/bin/bash

LEASES="/oma-polku/dnsmasq.lease"
OUTPUT="/oma-polku/backend/leases2.json"
TMP="/omapolku/backend/leases2.json.tmp"

SERVER="dhcp4"
MASK="<MASK>"
FIRST=1

echo "[" > "$TMP"

sanitize_json() {
    echo "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

while read -r END MAC IP HOST _; do
    [[ -z "$IP" ]] && continue
    [[ "$IP" == *:* ]] && continue

    IFS='.' read -r a b c d <<< "$IP"

    if [[ "$a" -eq 172 && "$b" -eq 30 && "$c" -ge 216 && "$c" -le 223 ]]; then
        HOST=$(sanitize_json "$HOST")
        MAC=$(sanitize_json "$MAC")

        END_HUMAN=$(TZ=Europe/Helsinki date -d "@$END" +"%Y/%m/%d %H:%M:%S")
        END_HUMAN=$(sanitize_json "$END_HUMAN")

        SUBNET_C=$(( (c / 8) * 8 ))
        SUBNET="${a}.${b}.${SUBNET_C}.0"

        [[ $FIRST -eq 0 ]] && echo "," >> "$TMP"
        FIRST=0

        printf '  {"server":"%s","ip":"%s","mac":"%s","hostname":"%s","subnet":"%s","mask":"%s","ends":"%s"}' \
            "$SERVER" "$IP" "$MAC" "$HOST" "$SUBNET" "$MASK" "$END_HUMAN" >> "$TMP"
    fi
done < "$LEASES"

echo "" >> "$TMP"
echo "]" >> "$TMP"

mv "$TMP" "$OUTPUT"
