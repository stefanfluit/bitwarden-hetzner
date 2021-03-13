#!/usr/bin/env bash

declare DIR
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "${DIR}../config.sh"

declare output_ssh_key
output_ssh_key$(< ${SSH_KEY})

ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_bitwarden -C admin+"${VPS_ENV}"@"${DOMAIN_ENV}"
sed -i "s/<ssh-key>/${output_ssh_key}/g" "${DIR}"../terraform/user_data.yml 

printf "Applying Terraform configuration\n"
cd "${DIR}"../terraform && terraform init &> /dev/null && terraform plan &> /dev/null && terraform apply -auto-approve &> /dev/null && printf "Done!\n"

declare BW_IP
BW_IP=$(terraform output | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

printf "Adding Bitwarden IP to AWS Route53..\n"
aws route53 change-resource-record-sets --hosted-zone-id Z1ZA9AAUY4V3Z4 --change-batch '{ "Comment": "BitWarden Rust", "Changes": [ { "Action": "CREATE", "ResourceRecordSet": { "Name": "'"${VPS_ENV}"'.'"${DOMAIN_ENV}"'", "Type": "A", "TTL": 120, "ResourceRecords": [ { "Value": "'"${BW_IP}"'" } ] } } ] }' >> /tmp/aws_log

declare max_timeout="6000"
declare timeout_at
timeout_at=$(( SECONDS + max_timeout ))

until ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519_bitwarden root@"${BW_IP}" '[ -d /var/lib/bitwarden_deploy ]'; do
  if (( SECONDS > timeout_at )); then
    printf "Maximum time of %s passed, stopping script.\n" "${max_timeout}" >&2
    exit 1
  fi
    printf "Cloud-init not done yet..\n" && sleep 5
done

printf "Directory exists, moving forward.\n" && sleep 2
printf "Copy the docker compose file and caddy file to server..\n"
scp -i ~/.ssh/id_ed25519_bitwarden -r "${DIR}"/docker-compose root@"${BW_IP}":/tmp &> /dev/null
ssh -i ~/.ssh/id_ed25519_bitwarden root@"${BW_IP}" "cp -r /tmp/docker-compose/* /var/lib/bitwarden_deploy" &> /dev/null
ssh -i ~/.ssh/id_ed25519_bitwarden root@"${BW_IP}" "docker-compose -f /var/lib/bitwarden_deploy/docker-compose.yml up -d" &> /dev/null && printf "Done! Access BitWarden now on https://%s.%s\n" "${VPS_ENV}" "${DOMAIN_ENV}"