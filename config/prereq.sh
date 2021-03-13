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

main() {
    aws &> /dev/null && printf "AWS is installed.\n" || install_aws
    terraform &> /dev/null && printf "Terraform is installed.\n" || install_terraform
}

main
