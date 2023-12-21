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
          image = data.hcp_packer_image.path-to-packer-container.labels["ImageDigest"]
          name  = "demo"
          port {
            container_port = 8080
          }
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}
