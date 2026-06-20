resource "random_string" "sql_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_mssql_server" "main" {
  name                         = "${var.name_prefix}-sql-${random_string.sql_suffix.result}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
  tags                         = var.tags
}

resource "azurerm_mssql_database" "main" {
  name         = "ir_rag_db"
  server_id    = azurerm_mssql_server.main.id
  collation    = "Japanese_CI_AS"
  max_size_gb  = 2
  sku_name     = "Basic"
  tags         = var.tags
}

# App ServiceからのアクセスをAzureサービス経由で許可
resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
