provider "aws" {
  region     = "eu-central-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

locals {
  name   = "kubuk-testr"  # Declare the local "name"
  region = "eu-central-1"  # Повернено до eu-central-1

  vpc_cidr = "10.123.0.0/16"
  azs      = ["eu-central-1a", "eu-central-1b"]

  public_subnets  = ["10.123.1.0/24", "10.123.2.0/24"]
  private_subnets = ["10.123.3.0/24", "10.123.4.0/24"]
  intra_subnets   = ["10.123.5.0/24", "10.123.6.0/24"]
}

# Add the VPC module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  intra_subnets   = local.intra_subnets

  enable_nat_gateway = true
}

resource "aws_instance" "EC2-Instance" {
  availability_zone      = "eu-central-1a"
  count                  = 1
  ami                    = "ami-0e04bcbe83a83792e"
  instance_type          = "c5a.xlarge"
  key_name               = "tolik"
  vpc_security_group_ids = [aws_security_group.oleg.id]

  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = 8
    volume_type           = "standard"
    delete_on_termination = true
    tags = {
      Name = "root-disk"
    }
  }

  user_data = file("sayt_jenkins_doer.sh")

  tags = {
    Name = "EC2-Instance"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true

  vpc_id                   = module.vpc.vpc_id  # Reference to the VPC module
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_ARM_64"
    instance_types = ["t4g.micro"]
    key_name       = "tolik"
    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    ascode-cluster-wg = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t4g.micro"]
      capacity_type  = "SPOT"

      tags = {
        Name = "EKS-Worker-Node"
      }
    }
  }

  tags = {
    Name = "EKS-cluster"
  }
}

resource "aws_security_group" "oleg" {
  name        = "oleg"
  description = "Allow 22, 80, 443, 8080, and other ports inbound traffic"

  dynamic "ingress" {
    for_each = [22, 80, 443, 8080, 8000, 81, 55555, 1433, 5034, 5173, 5181, 5432, 8220, 5601, 9600, 9300, 9090, 9100, 3000, 8081]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "oleg-security-group"
  }
}

# Додати S3 бакет
resource "aws_s3_bucket" "my_bucket" {
  bucket = "iamfirst"

  tags = {
    Name        = "My Terraform Bucket"
    Environment = "Dev"
  }
}
