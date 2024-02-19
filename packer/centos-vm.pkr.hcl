packer {
  required_plugins {
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
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
  sources = [
    "source.qemu.centos"
  ]

  provisioner "ansible" {
    groups        = ["webserver"]
    playbook_file = "./ansible/qemu-agent.yaml"
    only          = ["qemu.centos"]
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