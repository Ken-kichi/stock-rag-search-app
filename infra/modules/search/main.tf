resource "azurerm_search_service" "main" {
  name                = "${var.name_prefix}-search"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "standard"
  replica_count       = 1
  partition_count     = 1
  tags                = var.tags

  # セマンティック検索を有効化（Standard以上で利用可能）
  semantic_search_sku = "free"
}
