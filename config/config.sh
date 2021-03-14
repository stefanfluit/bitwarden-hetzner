#!/usr/bin/env bash

# Variables the script will ask you for, or not if defined here:
export HCLOUD_API_KEY="apitoken"

# Variables you should change:
export VPS_ENV="bitwarden"
export DOMAIN_ENV="example.com"

# Variables you can change, but not needed:
export SSH_KEY="/home/$(whoami)/.ssh/id_rsa.pub"
export HOST_KEY_FILE="/home/$(whoami)/.ssh/known_hosts"
export SSH_ID_RSA=$(echo "${SSH_KEY}" | cut -f1,2 -d'.')
export ADMIN_MAIL="admin@${DOMAIN_ENV}"
export LOG_LOC="/home/$(whoami)/.BW_HETZNER_RUST.LOG"
export SOURCE_IP=$(dig @resolver4.opendns.com myip.opendns.com +short)

# Remove this or uncomment if you're not using Route53:
export AWS_DNS_ZONE="<Zone ID>"