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

  chart      = "./cluster-issuer"

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

  depends_on = [ module.eks, helm_release.cert_manager, helm_release.external_dns, helm_release.nginx ]
}


### API Gateway
resource "helm_release" "api_gateway" {
  name = "api-gateway"

  chart      = "./api-gateway/helm"

  namespace  = "default"
  version    = "1.4.4"

  set {
    name  = "replicaCount"
    value = 1
  }

  depends_on = [ module.eks, helm_release.cert_manager, helm_release.external_dns, helm_release.nginx, helm_release.cluster_issuer ]
}


### DONT USE THIS
# resource "helm_release" "persistent_volume_fenix" {
#   name = var.pv_name

#   chart      = "./persistent-volumes/helm"

#   namespace  = "default"
#   set {
#     name  = "pv.fenix.volume_id"
#     value = "${var.ebs_volume_id}"
#   }

#   depends_on = [ helm_release.api_gateway ]
# }

# resource "helm_release" "prometheus" {
#   name       = "prometheus"
#   repository = "prometheus-community"
#   chart      = "prometheus"
#   version    = "14.11.1"

#   # set {
#   #   name  = "server.service.type"
#   #   value = "LoadBalancer"
#   # }

#   depends_on = [ helm_release.persistent_volume_fenix ]
# }