#!/usr/bin/env bash

# Variables the script will ask you for, or not if defined here:
export HCLOUD_API_KEY=""
export HCLOUD_DNS_KEY=""
# Hostname variable, e.g. "bitwarden", or leave empty, and the script will ask you.
export VPS_ENV=""
# Domain variable, e.g. "example.com", or leave empty, and the script will ask you.
export DOMAIN_ENV=""

# Other variables you don't have to change at all. 
export USER_=$(whoami)
export SSH_KEY="/home/${USER_}/.ssh/bw_key_id_rsa.pub"
export HOST_KEY_FILE="/home/${USER_}/.ssh/known_hosts"
export SSH_ID_RSA=$(echo "${SSH_KEY}" | cut -f1,2 -d'.')
export ADMIN_MAIL="admin@${DOMAIN_ENV}"
export LOG_LOC="/home/${USER_}/.BW_HETZNER_RUST.LOG"
export SOURCE_IP=$(dig @resolver4.opendns.com myip.opendns.com +short)
# Do not, if you change the directory TMP_API_DIR, end with a '/'. E.g., /var/lib/
export TMP_API_DIR="/tmp"

# Remove this or uncomment if you're not using Route53:
export AWS_DNS_ZONE="Zone ID"