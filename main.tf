

module "aws_lab" {

    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region     = "eu-west-2"

    source = "./aws_lab"
    lz_vpc = "10.100.0.0/21"
    az_vpc = "10.100.8.0/21"
    bz_vpc = "10.100.16.0/21"

}