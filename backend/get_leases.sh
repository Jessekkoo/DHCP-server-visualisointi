#!/bin/bash
set -euo pipefail

CONF="/home/teleste/serverit.conf"
OUT="/home/teleste"

if [[ ! -f "$CONF" ]]; then
    echo "VIRHE: conf-tiedostoa ei löydy: $CONF" >&2
    exit 1
fi

rm -f "${OUT}/"*.leases

exec < "$CONF"

while read -r name ip user type password; do
    [[ -z "$name" || "$name" == \#* ]] && continue

    [[ "$type" != "isc" ]] && continue

    echo "Haetaan leaset palvelimelta $name ($ip)..."

    if [[ "$password" == "yes" ]]; then
        if [[ -z "${SSH_PASS:-}" ]]; then
            echo "VIRHE: SSH_PASS ei ole asetettu (serveri $name)" >&2
            continue
        fi

        sshpass -e ssh -n -o BatchMode=no \
            -o StrictHostKeyChecking=no \
            "${user}@${ip}" \
            "cat /var/lib/dhcp/*.leases" \
            > "${OUT}/${name}.leases"

    else
        ssh -n -o BatchMode=yes \
            -o StrictHostKeyChecking=no \
            "${user}@${ip}" \
            "cat /var/lib/dhcp/*.leases" \
            > "${OUT}/${name}.leases"
    fi

done

echo "Lease-tiedostot haettu."
