resource "kubernetes_deployment" "demo_app" {
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
        container {
          image = "docker.io/bitnami/postgresql:15.4.0-debian-11-r10"
          name  = "demo"
          command = [
            "sh", "-c", "while : ; do ; echo hello ;sleep 5; done"
          ]

          volume_mount {
            name       = "secrets"
            mount_path = "/etc/secrets"
            read_only  = true
          }
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = [
                "ALL",
              ]
            }
            run_as_non_root = true
            run_as_user     = 1000680000
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
        security_context {
          fs_group = 1000680000
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
      }
    }
  }
}
