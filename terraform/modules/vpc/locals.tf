locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Derive three /24s per AZ for public, private, data tiers.
  public_subnet_cidrs  = [for idx in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, idx + 1)]
  private_subnet_cidrs = [for idx in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, idx + 101)]
  data_subnet_cidrs    = [for idx in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, idx + 201)]
}