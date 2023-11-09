data "azurerm_client_config" "current" {}

# Create our Resource Group - Demo
resource "azurerm_resource_group" "rg" {
  name     = "rg-demo"
  location = "westus2"
}

# Create our Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-demo"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create our Subnet to hold our VM - Virtual Machines
resource "azurerm_subnet" "sn" {
  name                 = "sn-demo"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create our Azure Storage Account
resource "azurerm_storage_account" "sa" {
  name                     = "sademo"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "demo"
  }
}

# Create our vNIC for our VM and assign it to our Virtual Machines Subnet
resource "azurerm_network_interface" "vmnic" {
  name                = "vmnic-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create our Virtual Machine VM01
resource "azurerm_linux_virtual_machine" "main" {
  name                  = "vm01-linux-demo"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.vmnic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "UAvm1OSdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "8"
    version   = "latest"
  }

  computer_name                   = "vm-linux-demo"
  admin_username                  = "azureuser"
  admin_password                  = "Qwerty123"
  disable_password_authentication = false

  tags = {
    environment = "Terraform Demo"
  }
}

resource "azurerm_mssql_server" "mssql" {
  name                         = "demo-sqlserver"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  version                      = "12.0"
  administrator_login          = "administrator"
  administrator_login_password = "Qwerty123"
}

resource "azurerm_mssql_database" "dbsql" {
  name           = "demo-dbs"
  server_id      = azurerm_mssql_server.mssql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "S0"
  zone_redundant = true

  tags = {
    environment = "Terraform Demo"
  }
}