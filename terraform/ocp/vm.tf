resource "kubernetes_manifest" "centos_vm" {
  manifest = {
    "apiVersion" = "kubevirt.io/v1"
    "kind"       = "VirtualMachine"
    "metadata" = {
      "labels" = {
        "app" = "centos-vm"
      }
      "name" = "centos-vm"
    }
    "spec" = {
      "dataVolumeTemplates" = [
        {
          "apiVersion" = "cdi.kubevirt.io/v1beta1"
          "kind"       = "DataVolume"
          "metadata" = {
            "name" = "centos-vm"
          }
          "spec" = {
            "source" = {
              "pvc" = {
                "name"      = "centos-vm-packer"
                "namespace" = "demo"
              }
            }
            "storage" = {
              "resources" = {
                "requests" = {
                  "storage" = "20Gi"
                }
              }
            }
          }
        },
      ]
      "running" = true
      "template" = {
        "metadata" = {
          "labels" = {
            "kubevirt.io/domain" = "centos-vm"
          }
        }
        "spec" = {
          "domain" = {
            "cpu" = {
              "cores"   = 1
              "sockets" = 2
              "threads" = 1
            }
            "devices" = {
              "disks" = [
                {
                  "disk" = {
                    "bus" = "virtio"
                  }
                  "name" = "rootdisk"
                },
                {
                  "disk" = {
                    "bus" = "virtio"
                  }
                  "name" = "cloudinitdisk"
                },
              ]
              "interfaces" = [
                {
                  "masquerade" = {}
                  "name"       = "default"
                },
              ]
              "rng" = {}
            }
            "resources" = {
              "requests" = {
                "memory" = "8Gi"
              }
            }
          }
          "evictionStrategy" = "LiveMigrate"
          "networks" = [
            {
              "name" = "default"
              "pod"  = {}
            },
          ]
          "volumes" = [
            {
              "dataVolume" = {
                "name" = "centos-vm"
              }
              "name" = "rootdisk"
            },
            {
              "cloudInitNoCloud" = {
                "userData" = <<-EOT
                #cloud-config
                user: cloud-user
                ssh_authorized_keys:
                  - ${tls_private_key.ssh_key.public_key_openssh}
                chpasswd: { expire: False }
                EOT
              }
              "name" = "cloudinitdisk"
            },
          ]
        }
      }
    }
  }
}
