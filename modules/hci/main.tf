resource "azapi_resource" "cluster" {
  type      = "Microsoft.AzureStackHCI/clusters@2023-08-01-preview"
  parent_id = var.resourceGroup.id
  name      = var.clusterName
  depends_on = [ azurerm_role_assignment.ServicePrincipalRoleAssign ]

  body = jsonencode({
    identity = {
      type = "SystemAssigned"
    }
    location   = var.resourceGroup.location
    properties = {}
  })

  ignore_body_changes = [
    "properties"
  ]
  timeouts {}
}

# Generate random integer suffix for storage account and key vault
resource "random_integer" "random_suffix" {
  keepers = {}
  min = 10
  max = 99
}
