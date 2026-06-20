terraform {
  required_version = ">= 1.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "azurerm" {
    resource_group_name  = "ir-rag-tfstate-rg"
    storage_account_name = "irragtfstate"
    container_name       = "tfstate"
    key                  = "ir-rag.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    cognitive_account {
      purge_soft_delete_on_destroy = true
    }
  }
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "storage" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags
  name_prefix         = var.name_prefix
}

module "sql" {
  source              = "./modules/sql"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags
  name_prefix         = var.name_prefix
  sql_admin_username  = var.sql_admin_username
  sql_admin_password  = var.sql_admin_password
}

module "search" {
  source              = "./modules/search"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags
  name_prefix         = var.name_prefix
}

module "openai" {
  source              = "./modules/openai"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.openai_location
  tags                = var.tags
  name_prefix         = var.name_prefix
}

module "app_service" {
  source              = "./modules/app_service"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags
  name_prefix         = var.name_prefix

  app_settings = {
    AZURE_OPENAI_ENDPOINT             = module.openai.endpoint
    AZURE_OPENAI_API_KEY              = module.openai.primary_key
    AZURE_OPENAI_DEPLOYMENT_CHAT      = var.openai_chat_deployment
    AZURE_OPENAI_DEPLOYMENT_EMBEDDING = var.openai_embedding_deployment
    AZURE_SEARCH_ENDPOINT             = module.search.endpoint
    AZURE_SEARCH_API_KEY              = module.search.primary_key
    AZURE_SEARCH_INDEX_NAME           = var.search_index_name
    SQL_SERVER                        = module.sql.server_fqdn
    SQL_DATABASE                      = module.sql.database_name
    SQL_USERNAME                      = var.sql_admin_username
    SQL_PASSWORD                      = var.sql_admin_password
    AZURE_STORAGE_CONNECTION_STRING   = module.storage.connection_string
    AZURE_STORAGE_CONTAINER           = var.storage_container_name
    TAVILY_API_KEY                    = var.tavily_api_key
    SCM_DO_BUILD_DURING_DEPLOYMENT    = "true"
  }
}
