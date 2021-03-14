[![Docker Pulls](https://img.shields.io/docker/pulls/bitwardenrs/server.svg)](https://hub.docker.com/r/bitwardenrs/server)
[![GitHub Release](https://img.shields.io/github/release/dani-garcia/bitwarden_rs.svg)](https://github.com/dani-garcia/bitwarden_rs/releases/latest)
[![GPL-3.0 Licensed](https://img.shields.io/github/license/dani-garcia/bitwarden_rs.svg)](https://github.com/dani-garcia/bitwarden_rs/blob/master/LICENSE.txt)


`Bitwarden Rust on Hetzner Cloud`
==========
Using this repository you can automatically run a Rust implementation of the Bitwarden backend using Terraform and Hetzner Cloud. The webserver/proxy is Caddy and the setup generates HTTPS certificate using Let's Encrypt. Update the variables in the config file and you are good to go. Read the Installation instructions before running anything. 

Prerequisites
===========

### DNS:
#
In order to succesfully generate a HTTPS cert using Let's Encrypt, this script uses AWS Route53 to update an A record with the Terraform outputted IP from the Hetzner server. If AWS is not setup on your system, the script will install it and ask for an API key itself. I changed the DNS line to a function in `bitwarden-hetzner/config/functions.sh` so you can easily change it. Just make sure to handle the variable IP properly.

### Terraform:
#
The Terraform binary should be available on your system in order to execute the script succesfully. You can find instructions here below. If you don't, the `prereq.sh` script will try to install Terraform for you. This is not tested yet and the script must be executed manually. `bash bitwarden-hetzner/config/prereq.sh` 

```
https://learn.hashicorp.com/tutorials/terraform/install-cli
```

### Hetzner Cloud:
# 
To create an account use the link below. You will need an API key for the environment you want the VM in. The script will ask for it at some point, or hardcode it in the `/bitwarden-hetzner/terraform/provider.tf`. 

#### Create an account:
```
https://accounts.hetzner.com/account/masterdata
```
#### Create an API key:
```
https://docs.hetzner.cloud/#authentication
```

`Installation:`
==========
Make sure you have Git installed:
```
sudo apt-get update && sudo apt-get install git -y
```
Clone this repo wherever you want it:
```
git clone https://github.com/stefanfluit/bitwarden-hetzner.git
```
Change the variables to whatever you want it:
```
vim bitwarden-hetzner/config/config.sh
```
Run the script:
```
cd bitwarden-hetzner/deploy_scripts && ./deploy_bitwarden.sh
```