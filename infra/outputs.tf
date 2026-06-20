output "app_service_url" {
  description = "StreamlitアプリのURL"
  value       = "https://${module.app_service.default_hostname}"
}

output "search_endpoint" {
  description = "Azure AI SearchエンドポイントURL"
  value       = module.search.endpoint
}

output "openai_endpoint" {
  description = "Azure OpenAIエンドポイントURL"
  value       = module.openai.endpoint
}

output "sql_server_fqdn" {
  description = "Azure SQL ServerのFQDN"
  value       = module.sql.server_fqdn
}

output "sql_database_name" {
  description = "データベース名"
  value       = module.sql.database_name
}

output "storage_account_name" {
  description = "Blob Storageアカウント名"
  value       = module.storage.account_name
}

output "storage_connection_string" {
  description = "Blob StorageへのConnection String"
  value       = module.storage.connection_string
  sensitive   = true
}

output "resource_group_name" {
  description = "リソースグループ名"
  value       = azurerm_resource_group.main.name
}
