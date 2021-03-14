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

install_aws() {
    wget https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
    unzip awscli-bundle.zip
    sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    ./awscli-bundle/install -b ~/bin/aws
    ./awscli-bundle/install -h
    aws configure
}

install_terraform() {
    curl -LO https://raw.github.com/robertpeteuil/terraform-installer/master/terraform-install.sh
    chmod +x terraform-install.sh
    ./terraform-install.sh
}

check_installed() {
  local -a progrs=("${@}")
  if [[ $# -eq 0 ]]
  then
    printf "No arguments supplied.\nSyntax is like:\n check_installed <Program 1..> <Program 2..> <Etc..> \n"
  fi
  for prog in "${progrs[@]}"; do
    if ! [[ -x "$(command -v "${prog}")" ]]; then
      printf "Program %s is not installed, installing..\n" "${prog}"
      install_${prog}
    else
      printf "Program %s is installed, proceeding..\n" "${prog}"
    fi
  done
}