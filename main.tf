resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# (опционально) подождать после RG
resource "time_sleep" "wait_after_rg" {
  depends_on      = [azurerm_resource_group.example]
  create_duration = "30s"
}

resource "azurerm_virtual_network" "main" {
  depends_on          = [time_sleep.wait_after_rg]
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# ¬ј∆Ќќ: подождать после VNet (уменьшает 404/УinconsistentФ на subnet)
resource "time_sleep" "wait_after_vnet" {
  depends_on      = [azurerm_virtual_network.main]
  create_duration = "90s"
}

resource "azurerm_subnet" "internal" {
  depends_on           = [time_sleep.wait_after_vnet]
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "time_sleep" "wait_after_subnet" {
  depends_on      = [azurerm_subnet.internal]
  create_duration = "45s"
}

resource "azurerm_network_interface" "main" {
  depends_on          = [time_sleep.wait_after_subnet]
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = var.vm_size

  delete_os_disk_on_termination = true
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "staging"
  }
}
