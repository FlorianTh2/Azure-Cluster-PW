resource "azurerm_subnet" "aks-subnet" {
  name                 = "${var.resource_prefix}-subnet"
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  resource_group_name  = azurerm_resource_group.aks_res_grp.name
  address_prefixes     = ["10.0.2.0/24"]
}

# cluster with system-pool-worker
resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                    = "${var.resource_prefix}aks"
  location                = azurerm_resource_group.aks_res_grp.location
  resource_group_name     = azurerm_resource_group.aks_res_grp.name
  kubernetes_version      = var.kubernetes_version
  private_cluster_enabled = false
  dns_prefix              = "${var.resource_prefix}-aks"

  default_node_pool {
    name                  = "systemnp"
    orchestrator_version  = var.kubernetes_version
    node_count            = 1
    vm_size               = "Standard_D2_v2"
    type                  = "VirtualMachineScaleSets"
    max_pods              = var.max_pods_per_node
    availability_zones    = ["1", "2"]
    enable_auto_scaling   = true
    min_count             = 1
    max_count             = 1
    os_disk_size_gb       = 30
    enable_node_public_ip = false

    vnet_subnet_id = azurerm_subnet.aks-subnet.id
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "calico"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {}
}

# cluster user-pool-worker
resource "azurerm_kubernetes_cluster_node_pool" "aks_cluster_user_pool" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-cluster.id
  name                  = "usernodepool"
  orchestrator_version  = var.kubernetes_version
  mode                  = "User"
  node_count            = 1
  vm_size               = "Standard_D2_v2"
  availability_zones    = ["1", "2"]
  enable_auto_scaling   = true

  os_type   = "Linux"
  min_count = 1
  max_count = 1
  max_pods  = var.max_pods_per_node
}
