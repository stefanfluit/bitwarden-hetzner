#!/usr/bin/env bash

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

main() {
    check_installed "aws" "terraform"
}

main
