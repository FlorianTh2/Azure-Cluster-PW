terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.42.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "1.3.0"
    }
  }
  required_version = "~> 0.14"
}

provider "azurerm" {
  features {}
}

provider "azuread" {}


variable "resource_prefix" {
  type        = string
  description = "(Required) Prefix given to all resources within the module."
  default     = "k8s"
}

variable "region" {
  type        = string
  description = "(Required) Specifies the supported Azure region where the resource exists. Changing this forces a new resource to be created."
  default     = "germanywestcentral"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.19.6"
  description = "Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)."
}

variable "max_pods_per_node" {
  type        = number
  default     = 100
  description = "Specifies the number of max pods per node (if increase: pay attention to the number of free ip-addresses in the given subnet)"
}

output "ssh_private_key_pem" {
  value = tls_private_key.ssh.private_key_pem
}

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.cluster.kube_config_raw
# }

# Resource Group
resource "azurerm_resource_group" "aks_res_grp" {
  name     = "${var.resource_prefix}-rg"
  location = var.region
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_ssh_public_key" "example" {
  name                = "ssh-terraform"
  resource_group_name = azurerm_resource_group.aks_res_grp.name
  location            = azurerm_resource_group.aks_res_grp.location
  public_key          = tls_private_key.ssh.public_key_openssh
}

# Networking
resource "azurerm_virtual_network" "aks_vnet" {
  name                = "${var.resource_prefix}-vnet"
  location            = azurerm_resource_group.aks_res_grp.location
  resource_group_name = azurerm_resource_group.aks_res_grp.name
  address_space       = ["10.0.0.0/16"]
}
