######
# merge defaults to populate unassigned params
# and create complete local settings reference
######

locals {
  # ensure agw priority is set if sku is of type "v2"
  # if nothing is provided, we will set to 1 for v2, or -1 to omit
  detect_priority = length(regexall("v2$", var.app_gateway.sku_tier)) > 0 ? 10 : null
  priority        = coalesce(var.app_gateway.priority, local.detect_priority, -1)

  # generate the resource names for everything based on the values offered
  names = {
    aks = coalesce(var.name, "${var.name_prefix}-aks")
    agw = coalesce(var.app_gateway.name, "${var.name_prefix}-agw")
  }

  # This block follows Azure Documentation for default node labels + taints
  # which is unique to each priority type.
  # details: https://docs.microsoft.com/en-us/azure/aks/spot-node-pool
  node_user_pool_defaults = {
    Regular = {
      node_labels = {}
      node_taints = []
    }
    Spot = {
      node_labels = {
        "kubernetes.azure.com/scalesetpriority" = "spot"
      }
      node_taints = [
        "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
      ]
    }
  }

  # merges the node_user_pool_defaults with the node_user_pool via
  # priority type (see above). Allows user to add values.
  # node_user_pool = var.node_user_pool
  node_user_pool_merged = {
    node_labels = merge(
      var.node_user_pool.node_labels,
      local.node_user_pool_defaults[var.node_user_pool.priority].node_labels
    )
    node_taints = concat(
      var.node_user_pool.node_taints,
      local.node_user_pool_defaults[var.node_user_pool.priority].node_taints
    )
  }

  # these are unmodified, just dropped into locals for consistency
  acr_list                  = var.acr_list
  app_gateway               = var.app_gateway
  automatic_channel_upgrade = var.automatic_channel_upgrade
  azure_policy              = var.azure_policy
  docker_bridge_cidr        = var.docker_bridge_cidr
  location                  = var.location
  node_default_pool         = var.node_default_pool
  node_user_pool            = var.node_user_pool
  oms                       = var.oms
  resource_group_name       = var.resource_group_name
  sku_tier                  = var.sku_tier
  subnet_id                 = var.subnet_id
  tags                      = var.tags
  waf_configuration         = var.waf_configuration
  zones                     = var.zones
}
