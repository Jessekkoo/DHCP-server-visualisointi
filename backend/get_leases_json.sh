#!/bin/bash

BASE="/oma-polku"
BACKEND="/oma-polku/backend"

OUTPUT="$BACKEND/leases.json"
TMP="$BACKEND/leases.json.tmp"
FIRST=1

echo "[" > "$TMP"

find_subnet() {
    local ip="$1"
    local conf="$2"

    IFS='.' read -r ip1 ip2 ip3 ip4 <<< "$ip"

    while read -r line; do
        if [[ "$line" =~ ^subnet[[:space:]]+([0-9\.]+)[[:space:]]+netmask[[:space:]]+([0-9\.]+) ]]; then
            SUB="${BASH_REMATCH[1]}"
            MASK="${BASH_REMATCH[2]}"

            IFS='.' read -r s1 s2 s3 s4 <<< "$SUB"
            IFS='.' read -r m1 m2 m3 m4 <<< "$MASK"

            if (( (ip1 & m1) == s1 && (ip2 & m2) == s2 && (ip3 & m3) == s3 && (ip4 & m4) == s4 )); then
                echo "$SUB $MASK"
                return 0
            fi
        fi
    done < "$conf"

    echo "0.0.0.0 0.0.0.0"
}

sanitize_json() {
    echo "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

for FILE in "$BASE"/dhcp*.leases; do
    SERVER=$(basename "$FILE" .leases)
    CONF="$BASE/${SERVER}.conf"

    IP=""
    MAC=""
    STARTS=""
    ENDS=""
    VENDOR=""

    while IFS= read -r LINE; do

        if [[ "$LINE" =~ ^lease[[:space:]]+([0-9\.]+)[[:space:]]*\{ ]]; then
            IP="${BASH_REMATCH[1]}"
        fi

        if [[ "$LINE" =~ starts[[:space:]]+[0-9]+[[:space:]]+([0-9\/]+)[[:space:]]+([0-9:]+) ]]; then
            STARTS="${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
        fi

        if [[ "$LINE" =~ ends[[:space:]]+[0-9]+[[:space:]]+([0-9\/]+)[[:space:]]+([0-9:]+) ]]; then
            ENDS="${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
        fi

        if [[ "$LINE" =~ ^[[:space:]]*hardware[[:space:]]+ethernet[[:space:]]+([0-9a-fA-F:]+)\; ]]; then
            MAC="${BASH_REMATCH[1],,}"
        fi

        if [[ "$LINE" =~ vendor-class-identifier ]]; then
            RAW=$(echo "$LINE" | sed -n 's/.*"\(.*\)".*/\1/p')
            VENDOR=$(sanitize_json "$RAW")
        fi

        if [[ "$LINE" == "}"* ]]; then
            if [[ -n "$IP" && -n "$STARTS" && -n "$ENDS" ]]; then

                read SUBNET MASK <<< "$(find_subnet "$IP" "$CONF")"

                [[ $FIRST -eq 0 ]] && echo "," >> "$TMP"
                FIRST=0

                printf '  {"server":"%s","ip":"%s","mac":"%s","subnet":"%s","mask":"%s","starts":"%s","ends":"%s","vendor":"%s"}' \
                    "$SERVER" "$IP" "$MAC" "$SUBNET" "$MASK" "$STARTS" "$ENDS" "$VENDOR" >> "$TMP"
            fi

            IP=""
            MAC=""
            STARTS=""
            ENDS=""
            VENDOR=""
        fi

    done < "$FILE"
done

echo "" >> "$TMP"
echo "]" >> "$TMP"

mv "$TMP" "$OUTPUT"

