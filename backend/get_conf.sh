#!/bin/bash

CONF="/home/teleste/serverit.conf"
OUT="/home/teleste/subnetit.txt"
TMP="/home/teleste/tmp_dhcp"

mkdir -p "$TMP"
> "$OUT"

echo "Subnetit (CIDR)" >> "$OUT"
echo "--------------" >> "$OUT"

exec < "$CONF"

while read -r name ip user type password; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    [[ "$type" != "isc" ]] && continue

    echo "# $name ($ip)" >> "$OUT"

    ssh -n "${user}@${ip}" \
        "cat /etc/dhcp/dhcpd.conf" \
        > "$TMP/${name}.conf"

    grep -E "^subnet .* netmask" "$TMP/${name}.conf" | \
    awk '
    {
      split($4,o,".");
      cidr=0;
      for(i=1;i<=4;i++){
        n=o[i]; while(n>0){ cidr+=n%2; n=int(n/2) }
      }
      print $2 "/" cidr
    }' >> "$OUT"

    echo "" >> "$OUT"
done

echo "Valmis! Subnetit tallennettu $OUT"

