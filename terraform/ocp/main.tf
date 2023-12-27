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
resource "kubernetes_service" "demo_app" {
  metadata {
    labels = {
      app = "demo-app"
    }
    name      = "demo-app"
    namespace = "demo"
  }
  spec {
    port {
      name        = "web"
      port        = 8080
      protocol    = "TCP"
      target_port = 8080
    }
    selector = {
      app = kubernetes_deployment.demo_app.metadata.0.labels.app
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "demo_app_route" {
  manifest = {
    "apiVersion" = "route.openshift.io/v1"
    "kind"       = "Route"
    "metadata" = {
      "labels" = {
        "app" = "demo-app"
      }
      "name"      = "demo-app"
      "namespace" = "demo"
    }
    "spec" = {
      "host" = "demo-app.crc-vm.${var.host_name}.instruqt.io"
      "port" = {
        "targetPort" = "web"
      }
      "tls" = {
        "insecureEdgeTerminationPolicy" = "Redirect"
        "termination"                   = "edge"
      }
      "to" = {
        "kind"   = "Service"
        "name"   = kubernetes_service.demo_app.metadata.0.name
        "weight" = 100
      }
      "wildcardPolicy" = "None"
    }
  }

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
            protocol       = "TCP"
            name           = "web"
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
