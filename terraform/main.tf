terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "metabase" {
  name     = "rg-metabase-prototype"
  location = "westus2"
}

resource "azurerm_virtual_network" "metabase_vnet" {
  name                = "vnet-metabase"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.metabase.location
  resource_group_name = azurerm_resource_group.metabase.name
}

resource "azurerm_subnet" "metabase_subnet" {
  name                 = "subnet-metabase"
  resource_group_name  = azurerm_resource_group.metabase.name
  virtual_network_name = azurerm_virtual_network.metabase_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "metabase_nsg" {
  name                = "nsg-metabase"
  location            = azurerm_resource_group.metabase.location
  resource_group_name = azurerm_resource_group.metabase.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "175.110.223.46/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Metabase"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "175.110.223.46/32"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "metabase_nsg_assoc" {
  subnet_id                 = azurerm_subnet.metabase_subnet.id
  network_security_group_id = azurerm_network_security_group.metabase_nsg.id
}

resource "azurerm_public_ip" "metabase_public_ip" {
  name                = "pip-metabase"
  resource_group_name = azurerm_resource_group.metabase.name
  location            = azurerm_resource_group.metabase.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "metabase_nic" {
  name                = "nic-metabase"
  location            = azurerm_resource_group.metabase.location
  resource_group_name = azurerm_resource_group.metabase.name

  ip_configuration {
    name                          = "metabase-ip-config"
    subnet_id                     = azurerm_subnet.metabase_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.metabase_public_ip.id
  }
}


resource "azurerm_linux_virtual_machine" "metabase_vm" {
  name                = "vm-metabase"
  resource_group_name = azurerm_resource_group.metabase.name
  location            = azurerm_resource_group.metabase.location
  size                = "Standard_D2als_v7"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.metabase_nic.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:/Users/majda/Desktop/proto-metabase-ssh/id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}