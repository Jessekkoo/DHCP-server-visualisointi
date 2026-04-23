#!/bin/bash
echo "Content-Type: application/json"
echo ""

jq -s 'add' \
  /home/teleste/backend/leases.json \
  /home/teleste/backend/leases2.json

