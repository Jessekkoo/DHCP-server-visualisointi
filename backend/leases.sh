#!/bin/bash
echo "Content-Type: application/json"
echo ""

jq -s 'add' \
  /oma-polku/backend/leases.json \
  /oma-polku/backend/leases2.json

