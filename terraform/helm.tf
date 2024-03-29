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

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  create_namespace = true
  namespace        = "kube-system"

  set {
    name  = "wait-for"
    value = module.cert_manager_irsa_role.iam_role_arn
  }

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com\\/role-arn"
    value = module.cert_manager_irsa_role.iam_role_arn
  }

  values = [
    "${file("helm_values/values-cert-manager.yaml")}"
  ]

  depends_on = [ module.eks ]
}

### External DNS
resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"

  create_namespace = true
  namespace        = "kube-system"

  set {
    name  = "wait-for"
    value = module.external_dns_irsa_role.iam_role_arn
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com\\/role-arn"
    value = module.external_dns_irsa_role.iam_role_arn
  }

  set {
    name  = "domainFilters"
    value = "{${var.domain}.${var.tld}}"
  }

  values = [
    "${file("helm_values/values-external-dns.yaml")}"
  ]

  depends_on = [ module.eks ]
}



### NGINX Ingress Controller
resource "helm_release" "nginx" {
  name       = "nginx-ingress"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"

  create_namespace = true
  namespace        = "nginx-ingress"

  depends_on = [ module.eks ]
}


### Cluster Issuer
resource "helm_release" "cluster_issuer" {
  name = "letsencrypt"

  chart      = "../cluster-issuer"

  namespace  = "default"
  version    = "0.1.0"

  set {
    name  = "environment"
    value = var.Environment
  }
  
  set {
    name  = "hostedZoneID"
    value = var.hostedZoneID
  }

  set {
    name  = "dns_domain"
    value = "${var.domain}.${var.tld}"
  }
  
  set {
    name  = "region"
    value = var.region
  }

  depends_on = [ module.eks, helm_release.cert_manager, helm_release.external_dns ]
}

data "aws_caller_identity" "current" {}


### API
resource "helm_release" "api" {
  name = var.api_name

  chart      = "../helm"

  namespace  = "default"
  version    = "1.4.4"

  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name = "aws_account_id"
    value = data.aws_caller_identity.current.account_id
  }

  set {
    name = "api_image_version"
    value = var.api_image_version
  }

  set {
    name = "sqs_url"
    value = aws_sqs_queue.my_queue.url
  }

  set {
    name = "api_name"
    value = var.api_name
  }

  set {
    name = "domain"
    value = var.domain
  }

  set {
    name = "tld"
    value = var.tld
  }

  set {
    name = "region"
    value = var.region
  }

  depends_on = [ module.eks, helm_release.cert_manager, helm_release.external_dns, helm_release.cluster_issuer ]
}
