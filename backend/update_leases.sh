#!/bin/bash

set -e

/home/teleste/backend/get_leases.sh
/home/teleste/backend/get_conf.sh
/home/teleste/backend/get_leases_json.sh
/home/teleste/backend/get_dnsmasq.sh
/home/teleste/backend/parse_leases2.sh

