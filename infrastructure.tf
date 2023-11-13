terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block        = var.vpc_cidr
  instance_tenancy  = "default"

  tags = {
    Name = "${var.PREFIX}-vpc"
  }
}

# Internet Gateway for the Public Subnets
resource "aws_internet_gateway" "int_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.PREFIX}_int_gateway"
  }
}

# Private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.PREFIX}_private_subnet"
  }
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "${var.PREFIX}_public_subnet"
  }
}

# Nat Gateway for private subnet
resource "aws_eip" "nat_gateway_eip" {
  vpc = true
  tags = {
    Name = "${var.PREFIX}_nat_gateway_eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "${var.PREFIX}_nat_gateway"
  }
}

# Public route table
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.int_gateway.id
  }

  tags = {
    Name = "${var.PREFIX}_public"
  }
}

# Private route table
resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.PREFIX}_private"
  }
}

# Associations
resource "aws_route_table_association" "assoc_1" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "assoc_2" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.route_table_private.id
}

# ECR repository
resource "aws_ecr_repository" "ECR_repository" {
  name                 = var.PREFIX
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.PREFIX}-cluster"

  setting {
    name = "containerInsights"
    value = "enabled"
  }
}

# Task execution role for used for ECS
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.PREFIX}_ecs_task_execution_role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

# Attach policy to task execution role
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "admin-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Secrets
resource "aws_secretsmanager_secret" "PAT" {
  name = "${var.PREFIX}-PAT"
}

resource "aws_secretsmanager_secret_version" "PAT_version" {
  secret_id     = aws_secretsmanager_secret.PAT.id
  secret_string = var.PAT
}

resource "aws_secretsmanager_secret" "ORG" {
  name = "${var.PREFIX}-ORG"
}

resource "aws_secretsmanager_secret_version" "ORG_version" {
  secret_id     = aws_secretsmanager_secret.ORG.id
  secret_string = var.ORG
}

resource "aws_secretsmanager_secret" "REPO" {
  name = "${var.PREFIX}-REPO"
}

resource "aws_secretsmanager_secret_version" "REPO_version" {
  secret_id     = aws_secretsmanager_secret.REPO.id
  secret_string = var.REPO
}

resource "aws_secretsmanager_secret" "AWS_DEFAULT_REGION" {
  name = "${var.PREFIX}-AWS_DEFAULT_REGION"
}

resource "aws_secretsmanager_secret_version" "AWS_DEFAULT_REGION_version" {
  secret_id     = aws_secretsmanager_secret.AWS_DEFAULT_REGION.id
  secret_string = var.AWS_DEFAULT_REGION
}