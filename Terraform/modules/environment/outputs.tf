output "resource_group" {
  value = "${azurerm_resource_group.k8s.name}"
}

output "aks_name" {
  value = "${azurerm_kubernetes_cluster.k8s_ingress.name}"
}

output "k8s-ingress" {
  value     = "${azurerm_kubernetes_cluster.k8s_ingress.kube_config_raw}"
  sensitive = true
}

output "host" {
  value = "${azurerm_kubernetes_cluster.k8s_ingress.kube_config.0.host}"
}
