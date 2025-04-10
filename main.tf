resource "azurerm_resource_group" "main" {
  name     = "${var.prefix_name}-rg"
  location = var.region
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix_name}-network"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix_name}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "vm" {
  source              = "./modules/vm"
  servers             = var.servers
  size_servers        = "Standard_B2ms"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = azurerm_subnet.main.id
  prefix_name         = var.prefix_name
  user                = var.user
  password            = var.password
}

module "gh" {
  source      = "./modules/gh"
  repo_name   = "KeyboardDeploy"
  webhook_url = "http://${lookup({ for server in module.vm.ip_servers : server.name => server.ip }, var.webhook_handler_url, "default_ip")}:80/github-webhook/"
}