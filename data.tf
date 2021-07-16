data "azurerm_container_registry" "acr" {
  name                = "mbbacr${var.environment}"
  resource_group_name = "rg_witcs_common-${var.environment}"
}
