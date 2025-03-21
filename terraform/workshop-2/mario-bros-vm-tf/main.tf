provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Create resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Call network module
module "network" {
  source = "./modules/network"

  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  virtual_network_name        = var.virtual_network_name
  address_space               = ["10.0.0.0/16"]
  subnet_name                 = var.subnet_name
  subnet_address_prefixes     = ["10.0.2.0/24"]
  public_ip_name              = var.public_ip_name
  network_interface_name      = var.network_interface_name
  network_security_group_name = var.network_security_group_name
}

# Call VM module
module "vm" {
  source = "./modules/vm"

  vm_name               = var.vm_name
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  vm_size               = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [module.network.network_interface_id]
}
