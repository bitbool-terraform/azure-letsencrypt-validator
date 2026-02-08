resource "azurerm_storage_account" "sa" {
  name                     = "stacctcontainerapps"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_storage_share" "share" {
  name                 = "shared‐files"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 100       # in GiB
}

resource "azurerm_container_app_environment_storage" "env_storage" {
  name                         = "fileshare‐mount"
  container_app_environment_id = azurerm_container_app_environment.ca_env.id

  account_name = azurerm_storage_account.sa.name
  share_name   = azurerm_storage_share.share.name

  # Use the storage account’s primary key to give the environment access
  access_key = azurerm_storage_account.sa.primary_access_key

  access_mode = "ReadWrite"
}