# Definition of the provider we will use
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Create the resource group, to which the other resources will be associated
resource "azurerm_resource_group" "rg" {
  name     = var.name_function
  location = var.location
}

# Create a Storage Account to associate it with the Function App (as recommended by the documentation).
resource "azurerm_storage_account" "sa" {
  name                     = var.name_function
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create the Service Plan resource to specify the service level 
# (for example, "Consumption", "Functions Premium", or "App Service Plan"), in this case "Y1" refers to the consumption plan
resource "azurerm_service_plan" "sp" {
  name                = var.name_function
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Windows"
  sku_name            = "B1"
}

# Create the Function App
resource "azurerm_windows_function_app" "wfa" {
  name                = var.name_function
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  service_plan_id            = azurerm_service_plan.sp.id

  site_config {
    application_stack {
      node_version = "~18"
    }
  }
}

# Create a function within the Function App
resource "azurerm_function_app_function" "faf" {
  name            = var.name_function
  function_app_id = azurerm_windows_function_app.wfa.id
  language        = "Javascript"
  # Load the example code into the function
  file {
    name    = "index.js"
    content = file("example/index.js")
  }
  # Define the payload for testing
  test_data = jsonencode({
    "name" = "Azure"
  })
  # Map the requests
  config_json = jsonencode({
    "bindings" : [
      {
        "authLevel" : "anonymous",
        "type" : "httpTrigger",
        "direction" : "in",
        "name" : "req",
        "methods" : [
          "get",
          "post"
        ]
      },
      {
        "type" : "http",
        "direction" : "out",
        "name" : "res"
      }
    ]
  })
}