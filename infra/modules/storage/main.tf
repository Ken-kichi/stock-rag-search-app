resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_storage_account" "main" {
  # ストレージアカウント名は3-24文字の英数字小文字のみ
  name                     = "${replace(var.name_prefix, "-", "")}st${random_string.storage_suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_container" "ir_pdfs" {
  name                  = "ir-pdfs"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# tfstateバックエンド用コンテナ（初回のみ手動作成が必要だが定義しておく）
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}
