# Create the Resource Group
resource azurerm_resource_group rg {
  name                         = "poc-rg"
  location                     = "eastus"
}

# Create the Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "la" {
  name                = "poc-log-analytics-workspace"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
}

# Create the Storage Account
resource "azurerm_storage_account" "sa" {
  name                     = "poctanujstorageaccount"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create the Blob Storage in the Storage Account
resource "azurerm_storage_container" "blob" {
  name                  = "poc-blob"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

# Enable the Diagnostic Settings for Storage Account
resource "azurerm_monitor_diagnostic_setting" "log-monitor" {
  name               = "poc-log-monitor"
  target_resource_id = azurerm_storage_account.sa.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id

  metric {
    category = "Transaction"

    retention_policy {
      enabled = false
    }
  }
}

# Enable Diagnostic Settings at the Blob Level
resource "azurerm_monitor_diagnostic_setting" "blobmon" {
   name               = "poc-blob-storage"
   target_resource_id = "${azurerm_storage_account.sa.id}/blobServices/default"
   log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
   
   log {
    category = "StorageRead"
    enabled  = true
retention_policy {
      enabled = false
    }
   }
   
   log {
    category = "StorageWrite"
    enabled  = true
retention_policy {
      enabled = false
    }
   }
   
   log {
    category = "StorageDelete"
    enabled  = true
retention_policy {
      enabled = false
    }
   }
metric {
     category = "Transaction"
retention_policy {
       enabled = false
     }
   }
 }

# To upload a file into the Blob Storage
resource "azurerm_storage_blob" "upload" {
  name                   = "result.csv"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.blob.name
  type                   = "Block"
  source                 = "result.csv"
  depends_on = [ azurerm_storage_account.sa ]
}
