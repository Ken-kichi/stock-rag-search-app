output "endpoint" {
  description = "Azure OpenAIエンドポイントURL"
  value       = azurerm_cognitive_account.main.endpoint
}

output "primary_key" {
  description = "Azure OpenAI APIキー"
  value       = azurerm_cognitive_account.main.primary_access_key
  sensitive   = true
}

output "chat_deployment_name" {
  description = "チャット用デプロイ名"
  value       = azurerm_cognitive_deployment.chat.name
}

output "embedding_deployment_name" {
  description = "埋め込み用デプロイ名"
  value       = azurerm_cognitive_deployment.embedding.name
}
