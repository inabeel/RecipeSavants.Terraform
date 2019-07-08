provider "helm" {
  version = "~> 0.9"
  
  kubernetes {
    host                   = "${azurerm_kubernetes_cluster.k8s_ingress.kube_config.0.host}"
    client_certificate     = "${base64decode(azurerm_kubernetes_cluster.k8s_ingress.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(azurerm_kubernetes_cluster.k8s_ingress.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.k8s_ingress.kube_config.0.cluster_ca_certificate)}"
  }
}

provider "tls" {
  version = "~> 2.0"
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "nginx" {
  name       = "nginx"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  chart      = "nginx-ingress"
  version    = "0.24.1"
  namespace  = "ingress-basic"
  
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
    value = "true"
  }
  set {
    name = "controller.replicaCount"
    value = "3"
  }
}

# cert-manager
resource "helm_release" "cert-manager" {
  name      = "cert-manager"
  chart     = "stable/cert-manager"
  namespace = "kube-system"
  timeout   = 1800
  depends_on = [ "helm_release.nginx" ]

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
  chart     = "${local.environment}/charts/letsencrypt/"
  namespace = "kube-system"
  timeout   = 1800
  depends_on = [ "helm_release.cert-manager" ]
}

# Found at: https://github.com/kubernetes/kubernetes/blob/master/pkg/cloudprovider/providers/azure/azure_loadbalancer.go#L38

# ServiceAnnotationLoadBalancerInternal is the annotation used on the service
# "service.beta.kubernetes.io/azure-load-balancer-internal"

# ServiceAnnotationLoadBalancerInternalSubnet is the annotation used on the service
# to specify what subnet it is exposed on
# "service.beta.kubernetes.io/azure-load-balancer-internal-subnet"

# ServiceAnnotationLoadBalancerMode is the annotation used on the service to specify the
# Azure load balancer selection based on availability sets
# There are currently three possible load balancer selection modes :
# 1. Default mode - service has no annotation ("service.beta.kubernetes.io/azure-load-balancer-mode")
#    In this case the Loadbalancer of the primary Availability set is selected
# 2. "__auto__" mode - service is annotated with __auto__ value, this when loadbalancer from any availability set
#    is selected which has the minimum rules associated with it.
# 3. "as1,as2" mode - this is when the load balancer from the specified availability sets is selected that has the
#    minimum rules associated with it.
# "service.beta.kubernetes.io/azure-load-balancer-mode"

# ServiceAnnotationLoadBalancerAutoModeValue is the annotation used on the service to specify the
# Azure load balancer auto selection from the availability sets
# "__auto__"

# ServiceAnnotationDNSLabelName is the annotation used on the service
# to specify the DNS label name for the service.
# "service.beta.kubernetes.io/azure-dns-label-name"

# ServiceAnnotationSharedSecurityRule is the annotation used on the service
# to specify that the service should be exposed using an Azure security rule
# that may be shared with other service, trading specificity of rules for an
# increase in the number of services that can be exposed. This relies on the
# Azure "augmented security rules" feature.
# "service.beta.kubernetes.io/azure-shared-securityrule"

# ServiceAnnotationLoadBalancerResourceGroup is the annotation used on the service
# to specify the resource group of load balancer objects that are not in the same resource group as the cluster.
# "service.beta.kubernetes.io/azure-load-balancer-resource-group"

# ServiceAnnotationAllowedServiceTag is the annotation used on the service
# to specify a list of allowed service tags separated by comma
# "service.beta.kubernetes.io/azure-allowed-service-tags"

# ServiceAnnotationLoadBalancerIdleTimeout is the annotation used on the service
# to specify the idle timeout for connections on the load balancer in minutes.
# "service.beta.kubernetes.io/azure-load-balancer-tcp-idle-timeout"

# ServiceAnnotationLoadBalancerMixedProtocols is the annotation used on the service
# to create both TCP and UDP protocols when creating load balancer rules.
# "service.beta.kubernetes.io/azure-load-balancer-mixed-protocols"
