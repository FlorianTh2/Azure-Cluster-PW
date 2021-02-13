# create service principal, role and authentication-secret the short way
#   az ad sp create-for-rbac \
#  --role="Contributor" \
#  --scopes="/subscriptions/SUBSCRIPTION_ID"
#
# terraform output azure-ssh-terraform.pem > ../keys/ssh/azure-ssh-terraform.pem
#
# az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)
#
# kubectl get pods --all-namespaces
#
# dashboard
# cluster-role-binding for k8s-dashboard
# kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard --user=clusterUser

# access k8s-dashboard through az (after that you may access http://127.0.0.1:8001/)
# az aks browse --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)

# create token in a new terminal-tab (dont interrupt "az aks browse"-process )
# kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep service-controller-token | awk '{print $1}')
# copy + paste the token to the dashboard

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
  default     = "K8s"
}

variable "region" {
  type        = string
  description = "(Required) Specifies the supported Azure region where the resource exists. Changing this forces a new resource to be created."
  default     = "germanywestcentral"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.19.3"
  description = "Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)."
}

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.cluster.kube_config_raw
# }

resource "azurerm_resource_group" "aks_res_grp" {
  name     = "${var.resource_prefix}-rg"
  location = var.region
}
