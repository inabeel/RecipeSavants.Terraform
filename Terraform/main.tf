module "efk" {
    source = "./modules/environment"
    environment = "efk"
    nodeCount = "2"
    subnet = "15.0.0.0/16"
}

module "ms" {
    source = "./modules/environment"
    environment = "ms"
    nodeCount = "3"
    subnet = "15.1.0.0/16"
}
