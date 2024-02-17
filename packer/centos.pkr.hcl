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
   required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
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
source "qemu" "centos" {
  iso_url          = "CentOS-7-x86_64-GenericCloud.qcow2c"
  disk_image       = "true"
  disk_size        = "10G"
  disk_compression = "true"
  iso_checksum     = "none"
  output_directory = "vm-image"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  format           = "qcow2"
  accelerator      = "kvm"
  ssh_username     = "root"
  ssh_password     = "s0m3password"
  headless         = "true"
  ssh_timeout      = "20m"
  vm_name          = "centos-vm-packer.qcow2"
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  boot_wait        = "10s"
  qemu_binary      = "qemu-kvm"
  qemuargs = [
    ["-display", "none"]
  ]

}

build {
  name = "vm"
  sources = [
    "source.qemu.centos"
  ]

  provisioner "ansible" {
    groups        = ["webserver"]
    playbook_file = "./ansible/qemu-agent.yaml"
  }

  provisioner "ansible" {
    groups        = ["webserver"]
    playbook_file = "./ansible/webserver.yaml"
  }

  post-processors {
      post-processor "shell-local" {
        inline = ["virtctl image-upload dv centos-vm-packer --size=10Gi  --force-bind --image-path vm-image/centos-vm-packer.qcow2 -n demo"]
        only   = ["qemu.centos"]
      }
  }
}

build {
  name = "container"
  sources = [
    "source.docker.centos"
  ]
  provisioner "ansible" {
    groups        = ["webserver"]
    playbook_file = "./ansible/webserver.yaml"
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
