resource "azurerm_kubernetes_cluster_extension" "flux" {
  name           = "flux"
  cluster_id     = azurerm_kubernetes_cluster.k8s.id
  extension_type = "microsoft.flux"
}

# TODO: Shift to using modules
resource "azurerm_kubernetes_flux_configuration" "cert_manager" {
  name       = "cert-manager"
  cluster_id = azurerm_kubernetes_cluster.k8s.id
  namespace  = "flux-system"

  git_repository {
    url             = "https://github.com/LouisDodgeAzure/AKS_CICD.git"
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name                      = "cert-manager"
    path                      = "kubernetes/cluster_services/cert-manager/overlays/dev"
    sync_interval_in_seconds  = 600 # 10 minutes
    retry_interval_in_seconds = 600 # 10 minutes
  }

  scope = "namespace"

  depends_on = [
    azurerm_kubernetes_cluster_extension.flux
  ]
}

# Define the Git repository and Flux configuration for your application
# resource "azurerm_kubernetes_flux_configuration" "app_dev" {
#   name       = "app-dev"
#   cluster_id = azurerm_kubernetes_cluster.k8s.id
#   namespace  = "flux-system"

#   git_repository {
#     url             = "https://github.com/LouisDodgeAzure/AKS_CICD.git"
#     reference_type  = "branch"
#     reference_value = "main"
#   }

#   kustomizations {
#     name                      = "app-dev"
#     path                      = "kubernetes/apps/overlays/dev"
#     sync_interval_in_seconds  = 300
#     retry_interval_in_seconds = 300
#     depends_on                = ["cert-manager"]
#   }

#   scope = "namespace"

#   # Make sure the app-dev configuration depends on cert-manager being successfully deployed
#   depends_on = [
#     azurerm_kubernetes_flux_configuration.cert_manager
#   ]
# }
