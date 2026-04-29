#!/bin/bash

JSON="leases.json"
LOG="/oma-polku/leasewatch.log"
DEBUG="/oma-polku/cron_debug.log"

JQ="/usr/bin/jq"

echo "Cron ajoi skriptin: $(TZ="Europe/Helsinki" date)" >> "$DEBUG"
echo "===== $(date) =====" >> "$LOG"

if [ ! -s "$JSON" ]; then
    echo "JSON-tiedosto puuttuu tai on tyhjä: $JSON" >> "$DEBUG"
    exit 1
fi

$JQ -c '.[]' "$JSON" | while read -r entry; do
    ip=$(echo "$entry" | $JQ -r '.ip')
    subnet=$(echo "$entry" | $JQ -r '.subnet')
    mask=$(echo "$entry" | $JQ -r '.mask')
    starts=$(echo "$entry" | $JQ -r '.starts')
    ends=$(echo "$entry" | $JQ -r '.ends')
    vendor=$(echo "$entry" | $JQ -r '.vendor')

    echo "IP: $ip  SUBNET: $subnet  MASK: $mask  STARTS: $starts  ENDS: $ends  VENDOR: $vendor" >> "$LOG"
done
