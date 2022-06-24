# First we create shared resource groups

resource "azurerm_resource_group" "data_rg" {
  location = local.location
  name     = var.data_rg_name
  tags     = local.data_rg_tags
}

resource "azurerm_resource_group" "aks_rg" {
  location = local.location
  name     = var.aks_rg_name
  tags     = local.aks_rg_tags
}

resource "azurerm_resource_group" "network_rg" {
  location = local.location
  name     = local.network_rg_name
  tags     = var.network_rg_tags
}

# Start creating data resources - storage accounts

resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.data_rg
  location                 = local.location
  account_kind             = var.storage_account_kind
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  min_tls_version          = var.sorage_min_tls_version
  is_hns_enabled           = var.is_hns_enabled
  access_tier              = var.storage_access_tier
  blob_public_access       = var.storage_blob_public_access
  versioning_enabled       = var.storage_versioning_enabled
  change_feed_enabled      = var.storage_change_feed_enabled
  nfsv3_enabled            = var.storage_nfsv3_enabled
  cross_tenant_replication_enabled = var.storage_cross_tenant_replication_enabled
  quota                    = var.file_shares_capacity
  infrastructure_encryption_enabled = var.storage_infrastructure_encryption_enabled

  provisioner "local-exec" {
    command = "az resource update --ids ${azurerm_storage_account.storage_account.id} --set properties.allowSharedKeyAccess=true"
  }

  network_rules {
    default_action             = "Allow"
    ip_rules                   = ["0.0.0.0"]
    virtual_network_subnet_ids = [azurerm_subnet.example.id]
    bypass                     = ["Metrics"]
  }

  blob_properties {
    delete_retention_policy {
        days = var.blob_delete_retention_policy
    }
  }

  tags                     = var.tags

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
