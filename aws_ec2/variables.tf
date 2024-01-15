variable "region" {

}

variable "access_key" {

}

variable "secret_key" {

}

variable "vpc_cidr_block" {

}

variable "public_subnets_cidr_blocks" {
  type        = list(any)
  description = "CIDR Block for Public Subnets"
}

variable "private_subnets_cidr_blocks" {
  type        = list(any)
  description = "CIDR Block for Private Subnets"
}

variable "availability_zones" {
  type        = list(any)
  description = "Subnet AZ"
}

variable "ami_id" {
  description = "AMI to use"
}