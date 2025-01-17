terraform {
    required_version = ">=1.0.0"
    required_providers {
        databricks = {
        source = "databricks/databricks"
        version = "1.63.0"
        }

        azurerm = {
            source = "hashicorp/azurerm"
            version = "~>4.0"
    }
}
}
provider "azurerm" {
    features {}

}
provider "databricks" {
    host = azurerm_databricks_workspace.example.workspace_url
}
provider "databricks" {
    alias = "accounts"
    host = "https://accounts.cloud.databricks.com"
  
}
