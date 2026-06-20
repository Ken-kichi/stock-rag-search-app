output "default_hostname" {
  description = "App ServiceのデフォルトホストURL（https://なし）"
  value       = azurerm_linux_web_app.main.default_hostname
}

output "app_service_id" {
  description = "App Service リソースID"
  value       = azurerm_linux_web_app.main.id
}

output "service_plan_id" {
  description = "App Service Plan リソースID（WebJobsが参照）"
  value       = azurerm_service_plan.main.id
}
