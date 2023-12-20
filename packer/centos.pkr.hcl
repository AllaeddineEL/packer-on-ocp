packer {
  required_plugins {
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/docker"
    }
  }
}

variable "ansible_host" {
  default = "default"
}

variable "ansible_connection" {
  default = "docker"
}

source "docker" "centos" {
  image  = "centos:7"
  commit = true
  run_command = ["-d", "-i", "-t", "--name", var.ansible_host, "{{.Image}}", "/bin/bash"]
  changes = [
    "USER nginx",
    "CMD [\"nginx\", \"-g\", \"daemon off;\"]"

  ]
}

build {
  sources = [
    "source.docker.centos"
  ]

  provisioner "ansible" {
    groups        = ["webserver"]
    playbook_file = "./webserver.yaml"
    extra_arguments = [
      "--extra-vars",
      "ansible_host=${var.ansible_host} ansible_connection=${var.ansible_connection}"
    ]
  }
  hcp_packer_registry {
    bucket_name = "path-to-packer-container"
    description = "Path to Packer Container Demo"
    bucket_labels = {
      "team" = "app-development",
      "os"   = "centos"
    }
    build_labels = {
      "build-time"   = timestamp(),
      "build-source" = basename(path.cwd)
      "local-image-reg-url" = "image-registry.openshift-image-registry.svc:5000"
    }
  }  
