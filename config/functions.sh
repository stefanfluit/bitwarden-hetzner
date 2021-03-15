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
    aws route53 change-resource-record-sets --hosted-zone-id "${AWS_DNS_ZONE}" --change-batch '{ "Comment": "BitWarden Rust", "Changes": [ { "Action": "CREATE", "ResourceRecordSet": { "Name": "'"${VPS_ENV}"'.'"${DOMAIN_ENV}"'", "Type": "A", "TTL": 120, "ResourceRecords": [ { "Value": "'"${IP_}"'" } ] } } ] }' &> /tmp/aws_log
}

install_aws() {
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  aws configure
}

install_terraform() {
    curl -LO https://raw.github.com/robertpeteuil/terraform-installer/master/terraform-install.sh
    chmod +x terraform-install.sh
    sudo ./terraform-install.sh
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
        cli_log "Input detected, API key is ${HCLOUD_API_KEY}"
      fi
  fi
}

check_hostname() {
  if [[ -z "${VPS_ENV}" ]]; then
    read -p "No hostname detected. What do you want the hostname to be? " VPS_INPUT
    export VPS_ENV=$(echo ${VPS_INPUT})
  else
    cli_log "Hostname detected, hostname is ${VPS_ENV}"
  fi
  if [[ -z "${DOMAIN_ENV}" ]]; then
    read -p "No domain detected. What do you want the domain to be? " DOMAIN_INPUT
    export DOMAIN_ENV=$(echo ${DOMAIN_INPUT})
  else
    cli_log "Domain detected, domain is ${DOMAIN_ENV}"
  fi
    cli_log "FQDN is ${VPS_ENV}.${DOMAIN_ENV}"
}

check_log_file() {
  if [ -f "$LOG_LOC" ]; then
      cli_log "Log file exist, adding note of this next run."
      printf "==============================================================\n" >> "${LOG_LOC}"
      printf "Run ID: $(date +%s%N | cut -b1-13)\n" >> "${LOG_LOC}"
      printf "==============================================================\n" >> "${LOG_LOC}"
  else 
      cli_log "${LOG_LOC} does not exist, creating it."
      touch "${LOG_LOG}" && cli_log "Created logfile." || cli_log "ERROR: Problems writing ${LOG_LOC}" && exit 1;
  fi
}

check_ssh_key() {
  # Will edit this later, right now it does not really make sense.
  if [ ! -e "${SSH_KEY}" ]; then
      cli_log "No SSH key found, generating one."
      ssh-keygen -b 4096 -t rsa -f "${SSH_ID_RSA}" -C "${ADMIN_MAIL}" -N "" &> /dev/null
      export SSH_KEY_OUTPUT=$(<${SSH_KEY})
  fi
}

run_init() {
  check_installed "aws" "terraform"
  check_hcloud_key
  check_log_file
  check_ssh_key
  check_hostname
}