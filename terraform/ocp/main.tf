data "hcp_packer_iteration" "path-to-packer-container" {
  bucket_name = "path-to-packer-container"
  channel     = "path-to-packer-container-channel"
}
data "hcp_packer_image" "path-to-packer-container" {
  bucket_name    = data.hcp_packer_iteration.path-to-packer-container.bucket_name
  iteration_id   = data.hcp_packer_iteration.path-to-packer-container.ulid
  cloud_provider = "docker"
  region         = "docker"
}
resource "kubernetes_service_account" "demo_app" {
  metadata {
    name      = "demo-app"
    namespace = "demo"
  }
  secret {
    name = kubernetes_secret.demo_app.metadata.0.name
  }
}

resource "kubernetes_secret" "demo_app" {
  metadata {
    name      = "demo-app"
    namespace = "demo"
  }
}
resource "kubernetes_manifest" "securitycontextconstraints_demo_app" {
  manifest = {
    "allowHostDirVolumePlugin" = true
    "allowHostNetwork"         = true
    "allowHostPorts"           = true
    "allowPrivilegedContainer" = true
    "apiVersion"               = "security.openshift.io/v1"
    "defaultAddCapabilities" = [
      "SYS_ADMIN",
    ]
    "fsGroup" = {
      "type" = "RunAsAny"
    }
    "kind" = "SecurityContextConstraints"
    "metadata" = {
      "name" = "demo-app"
    }
    "runAsUser" = {
      "type" = "RunAsAny"
    }
    "seLinuxContext" = {
      "type" = "RunAsAny"
    }
    "users" = [
      "system:serviceaccount:${kubernetes_service_account.demo_app.metadata.0.name}",
    ]
  }

}

resource "kubernetes_deployment" "demo_app" {
  depends_on = [kubernetes_manifest.securitycontextconstraints_demo_app]
  metadata {
    name      = "demo-app"
    namespace = "demo"
    labels = {
      app = "demo-app"
    }
  }

  spec {
    replicas = 1

    strategy {
      rolling_update {
        max_unavailable = "1"
      }
    }

    selector {
      match_labels = {
        app = "demo-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "demo-app"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.demo_app.metadata.0.name
        container {
          image = data.hcp_packer_image.path-to-packer-container.labels["ImageDigest"]
          name  = "demo"

          command = [
            "sh", "-c", "sleep 365"
          ]
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = [
                "ALL",
              ]
            }
            run_as_non_root = true
            run_as_user     = 1000650001
          }
          resources {
            limits = {
              cpu    = "0.5"
              memory = "64Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
        # security_context {
        #   fs_group = 1000680000
        #   seccomp_profile {
        #     type = "RuntimeDefault"
        #   }
        # }
      }
    }
  }
}
