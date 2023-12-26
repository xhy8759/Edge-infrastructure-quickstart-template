//Authorize RP
locals {
  SPRoleList = [
    # "Azure Connected Machine Resource Manager",
    "User Access Administrator",
    "contributor"
  ]
}

resource "azurerm_role_assignment" "ServicePrincipalRoleAssign" {
  for_each             = toset(local.SPRoleList)
  scope                = var.resourceGroup.id
  role_definition_name = each.value
  principal_id         = var.rp_principal_id
}



data "azurerm_client_config" "current" {}
resource "random_id" "twobyte" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = var.resourceGroup.name
  }

  byte_length = 2
}

resource "azurerm_key_vault" "DeploymentKeyVault" {
  name                = "${var.siteId}-kv-${random_id.twobyte.hex}"
  location            = var.resourceGroup.location
  resource_group_name = var.resourceGroup.name

  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  enabled_for_disk_encryption     = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  // arm template has enableSoftDelete": false, but terraform can't disable it after version 2.42.
  soft_delete_retention_days    = 30
  enable_rbac_authorization     = true
  public_network_access_enabled = true
  sku_name                      = "standard"

}

// TODO: Add RBAC to keyvault

resource "azurerm_key_vault_secret" "AzureStackLCMUserCredential" {
  name         = "AzureStackLCMUserCredential"
  content_type = "Secret"
  value        = base64encode("${var.domainAdminUser}:${var.domainAdminPassword}")
  key_vault_id = azurerm_key_vault.DeploymentKeyVault.id
  depends_on   = [azurerm_key_vault.DeploymentKeyVault]
}

resource "azurerm_key_vault_secret" "LocalAdminCredential" {
  name         = "LocalAdminCredential"
  content_type = "Secret"
  value        = base64encode("${var.localAdminUser}:${var.localAdminPassword}")
  key_vault_id = azurerm_key_vault.DeploymentKeyVault.id
  depends_on   = [azurerm_key_vault.DeploymentKeyVault]
}

resource "azurerm_key_vault_secret" "arbDeploymentSpnName" {
  name         = "DefaultARBApplication"
  content_type = "Secret"
  value        = base64encode("${var.servicePrincipalId}:${var.servicePrincipalSecret}")
  key_vault_id = azurerm_key_vault.DeploymentKeyVault.id
  depends_on   = [azurerm_key_vault.DeploymentKeyVault]
}

resource "azurerm_key_vault_secret" "storageWitnessName" {
  name         = "WitnessStorageKey"
  content_type = "Secret"
  value        = base64encode(azurerm_storage_account.witness.primary_access_key)
  key_vault_id = azurerm_key_vault.DeploymentKeyVault.id
  depends_on   = [azurerm_key_vault.DeploymentKeyVault]
}

//6. Get Arc server & assign roles to its system identity
# Get resources by type
module "serverRoleBindings" {
  for_each = {
    for index, server in var.servers :
    server.name => server.ipv4Address
  }
  source        = "./server-rolebindings"
  resourceGroup = var.resourceGroup
  serverName    = each.key
  subId         = var.subId
}
