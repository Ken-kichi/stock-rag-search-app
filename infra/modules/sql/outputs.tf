output "server_fqdn" {
  description = "SQL ServerのFQDN"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "database_name" {
  description = "データベース名"
  value       = azurerm_mssql_database.main.name
}

output "server_name" {
  description = "SQL Serverリソース名"
  value       = azurerm_mssql_server.main.name
}
