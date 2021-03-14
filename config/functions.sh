#!/usr/bin/env bash

cli_log() {
  local timestamp_
  timestamp_=$(date +"%H:%M")
  local arg_
  arg_="${1}"
  printf "Bitwarden Hetzner: %s: %s\n" "${timestamp_}" "${arg_}"
  printf "Bitwarden Hetzner: %s: %s\n" "${timestamp_}" "${arg_}" >> "${LOG_LOC}"
}

set_dns() {
    local IP_
    IP_="${1}"
    aws route53 change-resource-record-sets --hosted-zone-id "${AWS_DNS_ZONE}" --change-batch '{ "Comment": "BitWarden Rust", "Changes": [ { "Action": "CREATE", "ResourceRecordSet": { "Name": "'"${VPS_ENV}"'.'"${DOMAIN_ENV}"'", "Type": "A", "TTL": 120, "ResourceRecords": [ { "Value": "'"${IP_}"'" } ] } } ] }' >> /tmp/aws_log
}