#!/usr/bin/env bash

export VPS_ENV="bitwarden"
export DOMAIN_ENV="example.com"
export SSH_KEY="/home/$(whoami)/.ssh/id_rsa.pub"
export SSH_ID_RSA=$(echo "${SSH_KEY}" | cut -f1,2 -d'.')
export AWS_DNS_ZONE="Z1ZA9AAUY4V3Z4"
export ADMIN_MAIL="admin@${DOMAIN_ENV}"
