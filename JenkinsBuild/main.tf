provider "azurerm" {
  version = "1.43.0"
}

resource "azurerm_resource_group" "myResGroup" {
  name     = "Dev2"
  location = "eastus"
}

resource "azurerm_public_ip" "jenkinsServerPublicIP" {
  name                = "jenkinsServerIP"
  location            = azurerm_resource_group.myResGroup.location
  resource_group_name = azurerm_resource_group.myResGroup.name
  allocation_method   = "Static"
}

resource "azurerm_virtual_network" "example" {
  name                = "dev2-vnet"
  location            = azurerm_resource_group.myResGroup.location
  resource_group_name = azurerm_resource_group.myResGroup.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_network_interface" "jenkinsServerNIC_ID" {
  name                = "jenkinsNetworkInterface"
  location            = azurerm_resource_group.myResGroup.location
  resource_group_name = azurerm_resource_group.myResGroup.name

  ip_configuration {
    name                          = "JenkinsIPConfig"
    subnet_id                     = var.subnetID
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkinsServerPublicIP.id
  }
}
resource "azurerm_virtual_machine" "jenkinsServerVM" {
  name                  = "cloudskillsvm"
  location              = azurerm_resource_group.myResGroup.location
  resource_group_name   = azurerm_resource_group.myResGroup.name
  network_interface_ids = [azurerm_network_interface.jenkinsServerNIC_ID.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "cloudskillsdev01"
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/azureuser/.ssh/authorized_keys"
      key_data = file("~/.ssh/azure.pub")
    }
  }
  tags = {
    environment = "staging"
  }
}
