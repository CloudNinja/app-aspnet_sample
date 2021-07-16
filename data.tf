data "azurerm_container_registry" "acr" {
  name                = "cnacr${var.environment}"
  resource_group_name = "rg_common-${var.environment}"
}
