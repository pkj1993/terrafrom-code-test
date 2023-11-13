variable "PREFIX" {
    default = "ecs-runner"
}

variable "vpc_cidr" {
    description = "CIDR for the VPC"
    default = "20.0.0.0/16"
}

