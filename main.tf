
#provider "tls" {}

resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "key" {
    content = tls_private_key.deployer.private_key_pem
    filename = "${path.module}/key.pem"
    file_permission = "0400"
}

module "aws_lab" {

    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region     = "eu-west-2"
    public_key = tls_private_key.deployer.public_key_openssh
    private_key_pem = tls_private_key.deployer.private_key_pem

    source = "./aws_lab"
    lz_vpc = "10.100.0.0/21"
    az_vpc = "10.100.8.0/21"
    bz_vpc = "10.100.16.0/21"

}