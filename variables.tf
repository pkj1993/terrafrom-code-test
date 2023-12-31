variable "PREFIX" {
    default = "ecs-runner"
}

variable "vpc_cidr" {
    description = "CIDR for the VPC"
    default = "20.0.0.0/16"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "20.0.0.0/24"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "20.0.255.0/24"
}

variable "PAT" {}
variable "ORG" {}
variable "REPO" {
    default = "terrafrom-code-test"
}
variable "AWS_DEFAULT_REGION" {
    default = "ap-south-1"
}
variable "AWS_SECRET_ACCESS_KEY" {}
variable "AWS_ACCESS_KEY_ID" {}