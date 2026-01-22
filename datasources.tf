data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_subnet" "internal" {
  name                 = "internal"
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = data.azurerm_resource_group.main.name
}

data "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_virtual_machine" "main" {
  name                = "${var.prefix}-vm"
  resource_group_name = data.azurerm_resource_group.main.name
}

locals {
  public_ip_id   = try(data.azurerm_network_interface.main.ip_configuration[0].public_ip_address_id, null)
  public_ip_name = local.public_ip_id == null ? null : element(reverse(split("/", local.public_ip_id)), 0)
}

data "azurerm_public_ip" "main" {
  count               = local.public_ip_name == null ? 0 : 1
  name                = local.public_ip_name
  resource_group_name = data.azurerm_resource_group.main.name
}

locals {
  host_ip = local.public_ip_name != null ? data.azurerm_public_ip.main[0].ip_address : null
}
