output "storage_id" {
    value = azurerm_storage_account.tfstate.id
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}