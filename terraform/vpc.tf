module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = var.main_name
  cidr                 = "10.0.0.0/16"
  azs                  = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  public_subnet_tags = merge({
      "kubernetes.io/cluster/${var.main_name}" = "shared"
      "kubernetes.io/role/elb"                 = 1
    },
    var.tags
  )
  private_subnet_tags = merge(
    {
      "kubernetes.io/cluster/${var.main_name}" = "shared"
      "kubernetes.io/role/internal-elb"        = 1
    },
    var.tags
  )
  tags = var.tags
}
