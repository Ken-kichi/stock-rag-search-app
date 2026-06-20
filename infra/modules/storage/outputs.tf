output "account_name" {
  description = "Storageアカウント名"
  value       = azurerm_storage_account.main.name
}

output "connection_string" {
  description = "Storageへの接続文字列"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "ir_pdfs_container_name" {
  description = "IR PDF用コンテナ名"
  value       = azurerm_storage_container.ir_pdfs.name
}
