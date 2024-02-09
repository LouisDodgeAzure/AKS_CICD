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
    recreating_enabled        = true
  }

  scope = "namespace"

  depends_on = [
    azurerm_kubernetes_cluster_extension.flux
  ]
}

resource "kubernetes_cluster_role" "flux_crd_manager" {
  metadata {
    name = "flux-crd-manager"
  }

#   rule {
#     api_groups = ["apiextensions.k8s.io"]
#     resources  = ["customresourcedefinitions"]
#     verbs      = ["get", "list", "create", "update", "patch", "delete"]
#   }

#   rule {
#     api_groups = [""]
#     resources  = ["namespaces"]
#     verbs      = ["get", "list", "watch", "create", "patch", "update", "delete"]
#   }

  rule {
    api_groups = ["*"] # Wildcard for all API groups
    resources  = ["*"] # Wildcard for all resources
    verbs      = ["*"] # Wildcard for all verbs/actions
  }
}

resource "kubernetes_cluster_role_binding" "flux_crd_manager_binding" {
  metadata {
    name = "flux-crd-manager-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "flux-applier" // This should match the service account name used by Flux
    namespace = "flux-system"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.flux_crd_manager.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
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
