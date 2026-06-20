resource "azurerm_search_service" "main" {
  name                = "${var.name_prefix}-search"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "basic"
  replica_count       = 1
  partition_count     = 1
  tags                = var.tags

  # Semantic RankerはBasic以上で利用可能（無料枠: 1,000クエリ/月）
  semantic_search_sku = "free"
}
