resource "azurerm_resource_group" "example" {
  name     = "databricks-resources"
  location = "westeurope"
}

resource "azurerm_databricks_workspace" "example" {
  name                = "databricks-test"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "premium"

  tags = {
    Environment = "Production"
  }
}

resource "databricks_metastore" "this" {
  name          = "primary"
  force_destroy = true
  region        = "westeurope"
  storage_root = format("abfss://%s@%s.dfs.core.windows.net",
    azurerm_storage_container.ext_storage.name,
    azurerm_storage_account.ext_storage.name)
}

resource "databricks_metastore_assignment" "this" {
  workspace_id         = azurerm_databricks_workspace.example.workspace_id
  metastore_id         = databricks_metastore.this.id
  default_catalog_name = "data_metastore"
}

resource "azurerm_databricks_access_connector" "ext_access_connector" {
  name                = "ext-databricks-mi"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_account" "ext_storage" {
  name                     = "databricksextstorage6546"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "ext_storage" {
  name                  = "container-ext"
  storage_account_id  = azurerm_storage_account.ext_storage.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "ext_storage" {
  scope                = azurerm_storage_account.ext_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.ext_access_connector.identity[0].principal_id
}

