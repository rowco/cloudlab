
variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "region" {}

variable "lz_vpc" {}
variable "az_vpc" {}
variable "bz_vpc" {}

variable "private_key_pem" {}
variable "public_key" {}

#     public_key = tls_private_key.deployer.public_key_openssh
#     private_key_pem = tls_private_key.deployer.private_key_pem