data "azurerm_client_config" "current" {}

resource "random_password" "vmpassword" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_special      = 2
  special          = true
  override_special = "!@#$%&"

}

resource "azurerm_resource_group" "rg_name" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_key_vault" "kv" {
  name                            = var.keyvault_name
  resource_group_name             = azurerm_resource_group.rg_name.name
  location                        = azurerm_resource_group.rg_name.location
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.keyvault_sku
  enabled_for_template_deployment = true
  purge_protection_enabled        = false
  enable_rbac_authorization       = true
}

resource "azurerm_key_vault_secret" "vm-secret" {
  key_vault_id = azurerm_key_vault.kv.id
  name         = "${var.vm_name}-password"
  value        = random_password.vmpassword.result
  depends_on   = [azurerm_key_vault.kv]
}

resource "azurerm_virtual_network" "vnet-minikube" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = azurerm_resource_group.rg_name.location
  resource_group_name = azurerm_resource_group.rg_name.name
}

resource "azurerm_subnet" "vm-subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg_name.name
  virtual_network_name = azurerm_virtual_network.vnet-minikube.name
  address_prefixes     = var.subnets
  depends_on           = [azurerm_virtual_network.vnet-minikube]
}

resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.rg_name.location
  resource_group_name = azurerm_resource_group.rg_name.name

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                       = security_rule.value["name"]
      priority                   = security_rule.value["priority"]
      direction                  = security_rule.value["direction"]
      access                     = security_rule.value["access"]
      protocol                   = security_rule.value["protocol"]
      source_port_range          = security_rule.value["source_port_range"]
      destination_port_range     = security_rule.value["destination_port_range"]
      source_address_prefix      = security_rule.value["source_address_prefix"]
      destination_address_prefix = security_rule.value["destination_address_prefix"]
    }
  }
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.vm_name}-pip"
  location            = azurerm_resource_group.rg_name.location
  resource_group_name = azurerm_resource_group.rg_name.name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  sku_tier            = var.public_ip_sku_tier
}

resource "azurerm_network_interface" "nic" {
  name                 = "${var.vm_name}-nic"
  location             = azurerm_resource_group.rg_name.location
  resource_group_name  = azurerm_resource_group.rg_name.name
  enable_ip_forwarding = var.enable_ip_forwarding

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
  depends_on = [azurerm_subnet.vm-subnet]
}

resource "azurerm_network_interface_security_group_association" "nic-nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  resource_group_name             = azurerm_resource_group.rg_name.name
  location                        = azurerm_resource_group.rg_name.location
  size                            = var.vm_size
  admin_username                  = var.vm_username
  admin_password                  = random_password.vmpassword.result
  disable_password_authentication = var.disable_password_authentication
  custom_data                     = base64encode(data.template_file.linux-vm-cloud-init.rendered)
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  depends_on = [azurerm_subnet.vm-subnet]
}

data "template_file" "linux-vm-cloud-init" {
  template = file("script/user-data.sh")
}

resource "null_resource" "HelmChart-Install" {
  connection {
    type     = "ssh"
    host     = azurerm_public_ip.pip.ip_address
    user     = var.vm_username
    password = azurerm_key_vault_secret.vm-secret.value
  }
  provisioner "remote-exec" {
    inline = [
      "wget https://get.helm.sh/helm-v3.9.3-linux-amd64.tar.gz",
      "tar xvf helm-v3.9.3-linux-amd64.tar.gz",
      "sudo mv linux-amd64/helm /usr/local/bin",
      "rm -rf helm-v3.9.3-linux-amd64.tar.gz",
      "helm version"
    ]
  }
}
