#!/usr/bin/env bash

declare DIR
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

. "${DIR}/../config/config.sh"
. "${DIR}/../config/functions.sh"

cli_log "Making sure all the needed software is installed."
check_installed "aws" "terraform"

if [ ! -e "${SSH_KEY}" ]; then
    cli_log "No SSH key found, generating one."
    ssh-keygen -b 4096 -t rsa -f "${SSH_ID_RSA}" -C "${ADMIN_MAIL}" -N ""
    export SSH_KEY_OUTPUT=$(<${SSH_KEY})
fi 

sed -i "s|sshkey|${SSH_KEY_OUTPUT}|g" "${DIR}"/../terraform/user_data.yml 
sed -i "s|fqdn|${VPS_ENV}.${DOMAIN_ENV}|g" "${DIR}"/docker-compose/docker-compose.yml
sed -i "s|email|${ADMIN_MAIL}|g" "${DIR}"/docker-compose/docker-compose.yml 

cli_log "Applying Terraform configuration"
cd "${DIR}"/../terraform && terraform init && terraform plan && terraform apply -auto-approve && cli_log "Done!"

declare BW_IP
BW_IP=$(terraform output | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

cli_log "Bitwarden IP Address is ${BW_IP}"
cli_log "Adding Bitwarden IP to DNS."
set_dns "${BW_IP}" && cli_log "IP Succesfully updated." || cli_log "Something went wrong while trying to update DNS, Let's Encrypt will not work!"

declare max_timeout="6000"
declare timeout_at
timeout_at=$(( SECONDS + max_timeout ))

until ssh -o StrictHostKeyChecking=no -i "${SSH_ID_RSA}" root@"${BW_IP}" '[ -d /var/lib/bitwarden_deploy ]'; do
  if (( SECONDS > timeout_at )); then
    cli_log "Maximum time of %s passed, stopping script." "${max_timeout}" >&2
    exit 1
  fi
    cli_log "Cloud-init not done yet.." && sleep 5
done

cli_log "Directory exists, moving forward." && sleep 2
cli_log "Copy the docker compose file and caddy file to server.."
scp -i "${SSH_ID_RSA}" -r "${DIR}"/docker-compose root@"${BW_IP}":/tmp &> /dev/null
ssh -i "${SSH_ID_RSA}" root@"${BW_IP}" "cp -r /tmp/docker-compose/* /var/lib/bitwarden_deploy" &> /dev/null
ssh -i "${SSH_ID_RSA}" root@"${BW_IP}" "docker-compose -f /var/lib/bitwarden_deploy/docker-compose.yml up -d" &> /dev/null && cli_log "Done! Access BitWarden now on https://${VPS_ENV}.${DOMAIN_ENV}"
cli_log "Or, connect to the server using SSH: ssh admin@${VPS_ENV}.${DOMAIN_ENV}."
