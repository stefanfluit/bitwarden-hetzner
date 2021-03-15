#!/usr/bin/env bash

cli_log() {
  local timestamp_
  timestamp_=$(date +"%H:%M")
  local arg_
  arg_="${1}"
  printf "Bitwarden Hetzner - %s: %s\n" "${timestamp_}" "${arg_}"
  printf "Bitwarden Hetzner - %s: %s\n" "${timestamp_}" "${arg_}" >> "${LOG_LOC}"
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
    cli_log "No arguments supplied. Syntax is like: check_installed <Program 1..> <Program 2..> <Etc..>"
    exit 1;
  fi
  for prog in "${progrs[@]}"; do
    if ! [[ -x "$(command -v "${prog}")" ]]; then
      cli_log "Program ${prog} is not installed, installing.."
      install_${prog}
    else
      cli_log "Program ${prog} is installed, proceeding.."
    fi
  done
}

add_ssh_id() {
    # Use this function to add unknown key to known hosts without disabling host key verification check.
    local _id="${1}"
    local _ip=$(ping -q -c 1 -t 1 ${_id} | grep PING | sed -e "s/).*//" | sed -e "s/.*(//")
    ssh-keygen -R "${_id}" &> /dev/null
    ssh-keygen -R "${_ip}" &> /dev/null
    ssh-keygen -R "${_id}","${_ip}" &> /dev/null
    ssh-keyscan -H "${_id}","${_ip}" &> "${HOST_KEY_FILE}"
    ssh-keyscan -H "${_ip}" &> "${HOST_KEY_FILE}"
    ssh-keyscan -H "${_id}" &> "${HOST_KEY_FILE}"
}

check_hcloud_key() {
  if [ -n "${HCLOUD_API_KEY}" ]; then
    cli_log "API Key found: ${HCLOUD_API_KEY}"
  else
    cli_log "Set API key: " && read -s HCLOUD_API_KEY
      if [[ -z "${HCLOUD_API_KEY}" ]]; then
        cli_log "No input entered, exit script."
        exit 1;
      else
        # If userInput is not empty show what the user typed in and run ls -l
        cli_log "Input detected, API key is ${HCLOUD_API_KEY}"
      fi
  fi
}

check_log_file() {
  if [ -f "$LOG_LOC" ]; then
      cli_log "Log file exist, adding note of this next run."
      printf "==============================================================\n" >> "${LOG_LOC}"
      printf "Run ID: $(date +%s%N | cut -b1-13)" >> "${LOG_LOC}"
      printf "==============================================================\n" >> "${LOG_LOC}"
  else 
      cli_log "${LOG_LOC} does not exist, creating it."
      touch "${LOG_LOG}" && cli_log "Created logfile." || cli_log "ERROR: Problems writing ${LOG_LOC}" && exit 1;
  fi
}

run_init() {
  check_installed "aws" "terraform"
  check_hcloud_key
  check_log_file
}