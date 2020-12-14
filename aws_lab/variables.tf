variable "lz_vpc" {
  description = "The CIDR range for the LZ VPC"
  type        = string
  default     = ""
}
variable "az_vpc" {
  description = "The CIDR range for the AZ VPC"
  type        = string
  default     = ""
}
variable "bz_vpc" {
  description = "The CIDR range for the BZ VPC"
  type        = string
  default     = ""
}

variable "access_key" {}

variable "secret_key" {}

variable "region" {}
