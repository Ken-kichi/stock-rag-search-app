variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "name_prefix" {
  type = string
}

variable "app_settings" {
  description = "App Serviceに設定する環境変数"
  type        = map(string)
  default     = {}
  sensitive   = true
}
