module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "${var.main_name}-cluster"
  cluster_version = "1.27"

  # This is recommended only for testing purposes
  # cluster_endpoint_public_access       = true
  # cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  enable_irsa = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    min_size       = 1
    max_size       = 6
    desired_size   = 1
    instance_types = [var.instance_type]
    tags           = var.tags
    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
      "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
      "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
      "${aws_iam_policy.custom_sqs_policy.arn}"
    ]
    availability_zone = var.region
  }

  eks_managed_node_groups = {
    my_node_group = {
      name = var.main_name
      labels = {
        "infra" = "true"
      }
    }
  }

  # Adding required DNS Egress rule for Cert-Manager DNS challenge
  node_security_group_additional_rules = {
    egress_all = {
      description      = "Egress All"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  
  tags = var.tags
}
