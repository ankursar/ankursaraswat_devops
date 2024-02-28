rg_name       = "rg-minikube"
location      = "westus2"
keyvault_name = "kv-minikube"
keyvault_sku  = "standard"
vnet_name     = "vnet-minikube"
address_space = ["10.0.0.0/16"]
subnet_name   = "subnet-minikube"
subnets       = ["10.0.1.0/24"]
vm_name       = "vm-minikube"
vm_size       = "Standard_B4ms"
vm_username   = "vmadmin"
nsg_name      = "nsg-minikube"

nsg_rules = [
  {
    name                       = "Allowtohttp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]