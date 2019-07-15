provider "acme" {
  version = "~> 1.3"
  server_url = "${var.acme_server_url}"
}

resource "tls_private_key" "reg_private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = "${tls_private_key.reg_private_key.private_key_pem}"
  email_address   = "${var.acme_email}"
}

resource "tls_private_key" "cert_private_key" {
  algorithm = "RSA"
}

resource "tls_cert_request" "req" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.cert_private_key.private_key_pem}"
  dns_names       = ["*.${var.domain_url}"]

  subject {
    common_name = "${var.domain_url}"
  }
}

resource "acme_certificate" "certificate" {
  account_key_pem = "${acme_registration.reg.account_key_pem}"
  certificate_request_pem = "${tls_cert_request.req.cert_request_pem}"

  dns_challenge {
    provider = "azure"
    #     config = {
    #   AZURE_SUBSCRIPTION_ID = "${var.arm_subscription_id}"
    #   AZURE_CLIENT_ID       = "${var.arm_client_id}"
    #   AZURE_CLIENT_SECRET   = "${var.arm_client_secret}"
    #   AZURE_TENANT_ID       = "${var.arm_tenant_id}"
    #   AZURE_RESOURCE_GROUP  = "${azurerm_resource_group.k8s.name}"
    # }
  }  
}