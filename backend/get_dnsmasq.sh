#!/bin/bash
set -euo pipefail

CONF="/oma-polku/serverit.conf"
OUT="/oma-polku/"

DNSMASQ_PATH="/ssd1/.data/udapi-config/dnsmasq.lease"

if [[ ! -f "$CONF" ]]; then
    echo "VIRHE: conf-tiedostoa ei löydy: $CONF" >&2
    exit 1
fi

rm -f "${OUT}/"*.leases

exec < "$CONF"

while read -r name ip user type password; do
    [[ -z "$name" || "$name" == \#* ]] && continue

    [[ "$type" != "udm" ]] && continue

    echo "Haetaan dnsmasq.leaset palvelimelta $name ($ip)..."

    if [[ "$password" == "yes" ]]; then
        if [[ -z "${SSH_PASS:-}" ]]; then
            echo "VIRHE: SSH_PASS ei ole asetettu (serveri $name)" >&2
            continue
        fi

        sshpass -e scp \
            -o BatchMode=no \
            -o StrictHostKeyChecking=no \
            "${user}@${ip}:${DNSMASQ_PATH}" \
            "${OUT}/dnsmasq.lease"

    else
        scp \
            -o BatchMode=yes \
            -o StrictHostKeyChecking=no \
            "${user}@${ip}:${DNSMASQ_PATH}" \
            "${OUT}/dnsmasq.lease"
    fi

done

echo "dnsmasq lease-tiedostot haettu."
