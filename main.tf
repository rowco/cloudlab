resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "key" {
  content = tls_private_key.deployer.private_key_pem
  filename = "${path.module}/key.pem"
  file_permission = "0400"
}



# module "aws_lab" {

#     access_key = var.aws_access_key
#     secret_key = var.aws_secret_key
#     region     = "eu-west-2"

#     public_key = tls_private_key.deployer.public_key_openssh
#     private_key_pem = tls_private_key.deployer.private_key_pem

#     source = "./aws_lab"
#     lz_vpc = "10.100.0.0/21"
#     az_vpc = "10.100.8.0/21"
#     bz_vpc = "10.100.16.0/21"

# }

module "azure_lab" {
    source = "./azure_lab"

    subscription_id = var.azure_subscription_id
    tenant_id = var.azure_tenant_id
    client_id = var.azure_client_id
    client_secret = var.azure_client_secret
    region = "UK South"

    lz_vpc = "100.200.0.0/21"
    az_vpc = "100.200.8.0/21"
    bz_vpc = "100.200.16.0/21"

    public_key = tls_private_key.deployer.public_key_openssh
    private_key_pem = tls_private_key.deployer.private_key_pem
}