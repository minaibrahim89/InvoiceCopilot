terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.60.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "InvoiceCopilot-RG"
  location = "North Europe"
}

resource "azurerm_postgresql_flexible_server" "database-server" {
  name                   = "invoicecopilot-psqlflexibleserver"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "12"
  administrator_login    = "invoicecopilotadmin"
  administrator_password = "59QD7M*J%Amvje"
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
}

resource "azurerm_postgresql_flexible_server_database" "database" {
  name      = "invoicecopilotdb"
  server_id = azurerm_postgresql_flexible_server.database-server.id
  collation = "en_US.utf8"
  charset   = "UTF8"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}