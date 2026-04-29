#!/bin/bash

set -e

/oma-polku/backend/get_leases.sh
/oma-polku/backend/get_conf.sh
/oma-polku/backend/get_leases_json.sh
/oma-polku/backend/get_dnsmasq.sh
/oma-polku/backend/parse_leases2.sh

