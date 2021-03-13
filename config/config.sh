#!/usr/bin/env bash

export VPS_ENV="bitwarden_test"
export DOMAIN_ENV="fluit-online.nl"
export SSH_KEY="~/.ssh/id_rsa.pub"
export SSH_KEY_OUTPUT=$(cat ${SSH_KEY})
export AWS_DNS_ZONE="Z1ZA9AAUY4V3Z4"
export ADMIN_MAIL="stefan@fluit-online.nl"