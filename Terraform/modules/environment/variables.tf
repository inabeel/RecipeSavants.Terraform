resource "random_pet" "environment" {
}

variable "environment" {
  type        = "string"
  description = "Name of environment. Used to tag resources."
  default     = ""
}

variable "subnet" {
  type        = "string"
  description = "Subnet of environment. Used to partition out the address space. Use a /16 space."
  default     = "15.0.0.0/16"
}

variable "acme_email"{
  type= "string"
  description = "Email used for registering SSL certificate on Acme"
  default = "test@relliks.com"
}

variable "domain_url"{
  type= "string"
  description = "Domain used for registering SSL certificate on Acme"
}

variable "nodeCount"{
  type= "string"
  description = "Domain used for registering SSL certificate on Acme"
  default = "0"
}

variable "acme_server_url"{
  type= "string"
  description = "Acme server url for Lets Encrypt"
  default = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

variable "ssl_path_root"{
  type="string"
  description = "Location for SSL root"
  default = "/ssl"
}

locals {
  environment = "${var.environment == "" ? random_pet.environment.id : var.environment}"
}
