### Cert Manager

### Configure the Helm provider
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}



# data "aws_caller_identity" "current" {}


# ### API Gateway
# resource "helm_release" "api" {
#   name = "api"

#   chart      = "../helm"

#   namespace  = "default"
#   version    = "1.4.4"

#   set {
#     name  = "replicaCount"
#     value = 1
#   }

#   set {
#     name = "aws_account_id"
#     value = data.aws_caller_identity.current.account_id
#   }

#   set {
#     name = "api_image_version"
#     value = var.api_image_version
#   }

#   set {
#     name = "sqs_arn"
#     value = aws_sqs_queue.my_queue.arn
#   }

#   set {
#     name = "api_name"
#     value = var.api_name
#   }

#   set {
#     name = "domain"
#     value = var.domain
#   }

#   set {
#     name = "tld"
#     value = var.tld
#   }

#   set {
#     name = "region"
#     value = var.region
#   }

#   depends_on = [ module.eks ]
# }
