module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name = "wikijs-vpc"
  cidr = "10.0.0.0/16"

  azs = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c",
  ]

  # Public subnets
  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]

  # Private subnets
  private_subnets = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24",
  ]

  create_igw         = true
  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_support   = true
  enable_dns_hostnames = true

  # Public subnet tags
  public_subnet_tags = {
    Name = "wikijs-public-subnet"
  }

  # Private subnet tags
  private_subnet_tags = {
    Name = "wikijs-private-subnet"
  }

  # Route table tags
  public_route_table_tags = {
    Name = "wikijs-public-rt"
  }

  private_route_table_tags = {
    Name = "wikijs-private-rt"
  }

  default_route_table_tags = {
    Name = "wikijs-default-rt"
  }

  # NAT Gateway tag
  nat_gateway_tags = {
    Name = "wikijs-nat-gw"
  }

  # Internet Gateway tag
  igw_tags = {
    Name = "wikijs-igw"
  }

  # General VPC tags
  tags = {
    Name        = "wikijs-vpc"
    Project     = "WikiJS"
    Environment = "Assessment"
    ManagedBy   = "Terraform"
  }
}