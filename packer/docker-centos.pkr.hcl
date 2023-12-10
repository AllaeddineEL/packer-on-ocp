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

source "docker" "example" {
  image       = "centos:7"
  commit      = true
  run_command = ["-d", "-i", "-t", "--name", var.ansible_host, "{{.Image}}", "/bin/bash"]
}

build {
  sources = [
    "source.docker.example"
  ]

  provisioner "ansible" {
    groups        = ["webserver"]
    playbook_file = "./webserver.yaml"
    extra_arguments = [
      "--extra-vars",
      "ansible_host=${var.ansible_host} ansible_connection=${var.ansible_connection}"
    ]
  }
    
