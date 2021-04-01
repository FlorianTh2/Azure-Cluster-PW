resource "azurerm_public_ip" "jumphost_publicip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.aks_res_grp.location
  resource_group_name = azurerm_resource_group.aks_res_grp.name
  allocation_method   = "Dynamic"

  tags = {
    Name = "pip-jumphost"
  }
}

resource "azurerm_subnet" "jumphost-subnet" {
  name                 = "${var.resource_prefix}-subnet"
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  resource_group_name  = azurerm_resource_group.aks_res_grp.name
  address_prefixes     = ["10.0.1.0/24"]
}


resource "azurerm_network_security_group" "jumphost-nsg" {
  name                = "jumphostSecurityGroup"
  location            = azurerm_resource_group.aks_res_grp.location
  resource_group_name = azurerm_resource_group.aks_res_grp.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name = "jumphost-sg"
  }
}


resource "azurerm_network_interface" "jumphostnic" {
  name                = "jumphostNIC"
  location            = azurerm_resource_group.aks_res_grp.location
  resource_group_name = azurerm_resource_group.aks_res_grp.name

  ip_configuration {
    name                          = "jumphost-NicConfiguration"
    subnet_id                     = azurerm_subnet.jumphost-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jumphost_publicip.id
  }

  tags = {
    Name = "jumphost-nic"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.jumphostnic.id
  network_security_group_id = azurerm_network_security_group.jumphost-nsg.id
}


resource "azurerm_linux_virtual_machine" "jumphost-vm" {
  name                            = "jumphost-vm"
  location                        = azurerm_resource_group.aks_res_grp.location
  resource_group_name             = azurerm_resource_group.aks_res_grp.name
  network_interface_ids           = [azurerm_network_interface.jumphostnic.id]
  size                            = "Standard_D2_v2"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }



  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  tags = {
    Name = "jumphost-vm"
  }
}
