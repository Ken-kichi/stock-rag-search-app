output "endpoint" {
  description = "Azure AI SearchのエンドポイントURL"
  value       = "https://${azurerm_search_service.main.name}.search.windows.net"
}

output "primary_key" {
  description = "Azure AI Search 管理キー"
  value       = azurerm_search_service.main.primary_key
  sensitive   = true
}

output "service_name" {
  description = "Azure AI Searchサービス名"
  value       = azurerm_search_service.main.name
}
