variable "subscription_id" {
  description = "AzureサブスクリプションID"
  type        = string
}

variable "resource_group_name" {
  description = "リソースグループ名"
  type        = string
  default     = "ir-rag-rg"
}

variable "location" {
  description = "Azureリージョン"
  type        = string
  default     = "japaneast"
}

variable "openai_location" {
  description = "Azure OpenAIのリージョン（GPT-4o対応リージョン）"
  type        = string
  default     = "eastus"
}

variable "name_prefix" {
  description = "各リソース名のプレフィックス"
  type        = string
  default     = "ir-rag"
}

variable "tags" {
  description = "全リソースに付与する共通タグ"
  type        = map(string)
  default = {
    Project     = "ir-rag"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# SQL
variable "sql_admin_username" {
  description = "Azure SQL Server管理者ユーザー名"
  type        = string
  sensitive   = true
}

variable "sql_admin_password" {
  description = "Azure SQL Server管理者パスワード"
  type        = string
  sensitive   = true
}

# Storage
variable "storage_container_name" {
  description = "IR資料PDFを格納するBlobコンテナ名"
  type        = string
  default     = "ir-pdfs"
}

# Azure AI Search
variable "search_index_name" {
  description = "Azure AI Searchインデックス名"
  type        = string
  default     = "ir-documents"
}

# Azure OpenAI
variable "openai_chat_deployment" {
  description = "Azure OpenAI チャット用デプロイ名"
  type        = string
  default     = "gpt-4o"
}

variable "openai_embedding_deployment" {
  description = "Azure OpenAI 埋め込み用デプロイ名"
  type        = string
  default     = "text-embedding-3-large"
}

# Tavily Search API（Web検索によるIR資料発見）
variable "tavily_api_key" {
  description = "Tavily Search APIキー（https://app.tavily.com で取得）"
  type        = string
  sensitive   = true
}
