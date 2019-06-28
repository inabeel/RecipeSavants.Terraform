terraform {
  required_version = "=0.11.13"
}

provider "random" {
  version = "~> 2.1"
}

provider "azurerm" {
  version = "=1.24.0"
}

locals {
  azurerm_subnet_k8s-ingress_ip_address  = "${cidrhost(azurerm_subnet.k8s_lb.address_prefix, 100)}"
  azurerm_subnet_k8s-ingress_subnet_name = "${azurerm_subnet.k8s_lb.name}"
}

resource "azurerm_resource_group" "k8s" {
  name     = "k8s-${local.environment}"
  location = "Central US"
  
  tags = {
    environment = "${local.environment}"
  }
}

resource "azurerm_virtual_network" "k8s" {
  name                = "network-${local.environment}"
  location            = "${azurerm_resource_group.k8s.location}"
  resource_group_name = "${azurerm_resource_group.k8s.name}"
  address_space       = ["${var.subnet}"]
  
  tags = {
    environment = "${local.environment}"
  }
}

resource "azurerm_subnet" "appgwsubnet" {
  name                 = "application-gateway"
  virtual_network_name = "${azurerm_virtual_network.k8s.name}"
  resource_group_name  = "${azurerm_resource_group.k8s.name}"
  address_prefix       = "${cidrsubnet(var.subnet, 8, 0)}"
}

resource "azurerm_subnet" "k8s_ingress" {
  name                 = "kubernetes-nodes"
  virtual_network_name = "${azurerm_virtual_network.k8s.name}"
  resource_group_name  = "${azurerm_resource_group.k8s.name}"
  address_prefix       = "${cidrsubnet(var.subnet, 8, 1)}"
}

resource "azurerm_subnet" "k8s_lb" {
  name                 = "kubernetes-loadbalancers"
  virtual_network_name = "${azurerm_virtual_network.k8s.name}"
  resource_group_name  = "${azurerm_resource_group.k8s.name}"
  address_prefix       = "${cidrsubnet(var.subnet, 8, 2)}"
}
