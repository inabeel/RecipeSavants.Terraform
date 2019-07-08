module "efk" {
    source = "./modules/environment"
    environment = "efk"
    acme_email = "nabeel@relliks.com"
    domain_url = "example1.com"
    nodeCount = "2"
    subnet = "15.0.0.0/16"
    ssl_path_root = "/ssl"
}

module "ms" {
    source = "./modules/environment"
    environment = "ms"
    nodeCount = "3"
    acme_email = "nabeel@relliks.com"
    domain_url = "example2.com"
    subnet = "15.1.0.0/16"
    ssl_path_root = "/ssl"
}
