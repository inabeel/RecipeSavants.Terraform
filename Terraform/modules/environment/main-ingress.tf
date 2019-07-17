# ingress ip
resource "azurerm_public_ip" "ingress_ip" {
  name                = "RecipeSavants-${local.environment}-iip"
  location            = "${azurerm_resource_group.k8s.location}"
  resource_group_name = "${azurerm_resource_group.k8s.name}"

  allocation_method = "Static"
  domain_name_label = "recipesavants-${local.environment}"

  tags = {
    project = "RecipeSavants"
    instance = "${local.environment}-instance"
    environment = "${local.environment}-environment"
  }
}

# helm provider
provider "helm" {
  version = "~> 0.10"
  kubernetes {
    host                   = "${azurerm_kubernetes_cluster.k8s_ingress.kube_config.0.host}"
    client_certificate     = "${base64decode(azurerm_kubernetes_cluster.k8s_ingress.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(azurerm_kubernetes_cluster.k8s_ingress.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.k8s_ingress.kube_config.0.cluster_ca_certificate)}"
  }
}

# ingress
resource "helm_release" "ingress" {
  name      = "ingress-${local.environment}"
  chart     = "stable/nginx-ingress"
  namespace = "kube-system"
  timeout   = 1800

  set {
    name  = "controller.service.loadBalancerIP"
    value = "${azurerm_public_ip.ingress_ip.ip_address}"
  }
  set {
    name = "controller.service.annotations.\"service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group\""
    value = "${azurerm_resource_group.k8s.name}"
  }
  set {
    name  = "rbac.create"
    value = "false"
  }
}

# cert-manager
resource "helm_release" "cert-manager" {
  name      = "cert-manager"
  chart     = "stable/cert-manager"
  namespace = "kube-system"
  timeout   = 1800
  depends_on = [ "helm_release.ingress" ]

  set {
    name  = "ingressShim.defaultIssuerName"
    value = "letsencrypt"
  }
  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }
  set {
    name  = "rbac.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
}

# letsencrypt
resource "helm_release" "letsencrypt" {
  name      = "letsencrypt"
  chart     = "${path.root}/charts/letsencrypt/"
  namespace = "kube-system"
  timeout   = 1800
  depends_on = [ "helm_release.cert-manager" ]
}