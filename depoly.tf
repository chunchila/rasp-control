# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = "3abd0dd5-602a-4620-b1f8-d53bf2a6dbad"
    client_id       = "f481799b-ac0f-4765-a2a1-8f7035da8cbd"
    client_secret   = "3f1f48be-9406-4085-a8d1-14e07b8b73b8"
    tenant_id       = "d973bda2-a09e-44fe-9c85-c7ff5ea46be0"
}


variable "vms" {
    default = 10
  
}

# get az tenent id 
#az account show --query "{subscriptionId:id, tenantId:tenantId}"

# create net application registration 
#az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/3abd0dd5-602a-4620-b1f8-d53bf2a6dbad"



## az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/3abd0dd5-602a-4620-b1f8-d53bf2a6dbad" 
#f481799b-ac0f-4765-a2a1-8f7035da8cbd	azure-cli-2018-12-08-18-31-57	http://azure-cli-2018-12-08-18-31-57	3f1f48be-9406-4085-a8d1-14e07b8b73b8	d973bda2-a09e-44fe-9c85-c7ff5ea46be0


# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "myResourceGroup"
    location = "eastus"

    tags {
        environment = "Terraform Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    tags {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    count                        = "${var.vms}"
    name                         = "myPublicIP-${count.index}-moshe"
    location                     = "eastus"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

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

    tags {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    count                     = "${var.vms}"
    name                      = "myNIC-${count.index}"
    location                  = "eastus"
    resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

   
   
    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.myterraformpublicip.*.id,count.index)}"

    }
    

    tags {
        environment = "Terraform Demo"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.myterraformgroup.name}"
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.myterraformgroup.name}"
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags {
        environment = "Terraform Demo"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    count                 = "${var.vms}" 
    name                  = "myVM-${count.index}"
    location              = "eastus"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${element(azurerm_network_interface.myterraformnic.*.id,count.index)}"]
    vm_size               = "Standard_DS1_v2"
    
    

    storage_os_disk {
        name              = "myOsDisk-${count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4OqtycBTD1RYNhPW1s4IiuyG61H0M+0FnRfUOqdTJhcU84alJzWbkRXAGAh42+3rm0mXiFc2uGkP2v/F7XcfBFxrWkgg0rycQ4aZZ8PG0as939WHm3tU1M9KAqzHnv9OjZZqqhici/taA9xJCnRCl4TLdYAhIs72Sy0uuFxdYrk19rTmsP+HzGUkRMyFaJTM+jntXhwooujIqQQ1QJyoXgatnIhSTzggemFn3aBbfwz7ivDDnUwl2yq7ZnEtqLIXWRXBhGnXd1SDJK9rabsvmxqeX8QXs3IJXpsCO0dDW3VEUdeXlNa5osIP5f4H/HXF0z2Km7dfWKNuWyltCI+tX romanrozin@Romans-MacBook-Pro.local"
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "Terraform Demo"
        name = "${random_id.randomId.id}"
    }
   
   provisioner "local-exec" {
    command = "sleep 4"
    #interpreter = ["perl", "-e"]
  }



}

 output "public_ip_address" {
    description = "The actual ip address allocated for the resource."
    value       = "azurerm_public_ip.myterraformpublicip.ip_address"
    }
