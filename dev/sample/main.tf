module "base" {
  source          = "../../modules/base"
  location        = "eastus"
  siteId          = basename(abspath(path.module))
  domainFqdn      = "jumpstart.local"
  startingAddress = "192.168.1.55"
  endingAddress   = "192.168.1.65"
  defaultGateway  = "192.168.1.1"
  dnsServers      = ["192.168.1.254"]
  adouSuffix      = "DC=jumpstart,DC=local"
  domainServerIP  = "10.1.0.4"
  servers = [
    {
      name        = "AzSHOST1",
      ipv4Address = "192.168.1.12"
    },
    {
      name        = "AzSHOST2",
      ipv4Address = "192.168.1.13"
    }
  ]
  managementAdapters = ["FABRIC", "FABRIC2"]
  storageNetworks = [
    {
      name               = "Storage1Network",
      networkAdapterName = "StorageA",
      vlanId             = "711"
    },
    {
      name               = "Storage2Network",
      networkAdapterName = "StorageB",
      vlanId             = "712"
    }
  ]
  rdmaEnabled                   = false     // Change to true if RDMA is enabled.
  storageConnectivitySwitchless = false     // Change to true if storage connectivity is switchless.
  enableProvisioners            = true      // Change to false when Arc servers are connected by yourself.
  authenticationMethod          = "Credssp" // or "Default"
  subscriptionId                = var.subscription_id
  domainAdminUser               = var.domain_admin_user
  domainAdminPassword           = var.domain_admin_password
  localAdminUser                = var.local_admin_user
  localAdminPassword            = var.local_admin_password
  deploymentUserPassword        = var.deployment_user_password
  servicePrincipalId            = var.service_principal_id
  servicePrincipalSecret        = var.service_principal_secret
  rpServicePrincipalObjectId    = var.rp_service_principal_object_id

  # Region HCI logical network parameters
  lnet-startingAddress = "192.168.1.171"
  lnet-endingAddress   = "192.168.1.190"
  lnet-addressPrefix   = "192.168.1.0/24"
  lnet-defaultGateway  = "192.168.1.1"
  lnet-dnsServers      = ["192.168.1.254"]

  # Region AKS Arc parameters
  aksArc-controlPlaneIp   = "192.168.1.190"                          # An IP address in the logical network IP range.
  rbacAdminGroupObjectIds = ["ed888f99-66c1-48fe-992f-030f49ba50ed"] # An AAD group that will have the admin permission of this AKS Arc cluster. Check ./doc/AKS-Arc-Admin-Groups.md for details

  # Region HCI VM parameters
  # Uncomment this section will create a windows server VM on HCI.
  downloadWinServerImage = true
  vmAdminPassword        = var.vm_admin_password
  domainJoinPassword     = var.domain_join_password

  # Region site manager parameters
  # Uncomment this section will create site manager instance for the resource group.
  # Check ./doc/Add-Site-Manager.md for more information
  country = "US"
}
