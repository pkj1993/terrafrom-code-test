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

variable "PAT" {
    default = "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"
}
variable "ORG" {
    default = "pkj1993"
}